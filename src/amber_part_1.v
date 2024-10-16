Require Import Metalib.Metatheory.
Require Import Program.Equality.
Require Export definition.
Require Export infra.
Require Export subtyping.

Definition env_amber := list (atom * atom).

Fixpoint domA (E : env_amber) : atoms :=
  match E with
  | nil => {}
  | (X,Y)::E' => {{X}} \u {{Y}} \u domA E'
  end.

(** Well-formed Environment *)
Inductive wfe_amber: env_amber -> Prop :=
| wfea_base:
    wfe_amber nil
| wfea_cons: forall X Y E,
    X \notin domA E ->
    Y \notin {{X}} \u domA E ->
    wfe_amber E ->
    wfe_amber ((X,Y)::E).

(** Well-formed Types for amber rules *)
Inductive wf_amber: env_amber -> typ -> Prop :=
| wfa_nat: forall E,
    wfe_amber E ->
    wf_amber E typ_nat
| wfa_top: forall E,
    wfe_amber E ->
    wf_amber E typ_top
| wfa_fvarl: forall E X Y,
    In (X,Y) E ->
    wfe_amber E ->
    wf_amber E X
| wfa_fvarr: forall E X Y,
    In (X,Y) E ->
    wfe_amber E ->
    wf_amber E Y
| wfa_arrow: forall E A1 A2,
    wf_amber E A1 ->
    wf_amber E A2 ->
    wf_amber E (typ_arrow A1 A2)
| wfa_rec: forall E A L,
    (forall X Y,
        X \notin L -> Y \notin L \u {{X}} ->
        wf_amber (X ~ Y ++ E) (open_tt A X)) ->
    wf_amber E (typ_mu A).
    
(** Folkfore Amber rules *)
Inductive sub_amber: env_amber -> typ -> typ -> Prop :=
| sam_nat: forall E,
    wfe_amber E ->
    sub_amber E typ_nat typ_nat
| sam_top: forall E A,
    wf_amber E A ->
    wfe_amber E ->
    sub_amber E A typ_top
| sam_fvar: forall E X Y,
    In (X, Y) E ->
    wfe_amber E ->
    sub_amber E (typ_fvar X) (typ_fvar Y)
| sam_arrow: forall E A1 A2 B1 B2,
    sub_amber E B1 A1 ->
    sub_amber E A2 B2 ->
    sub_amber E (typ_arrow A1 A2) (typ_arrow B1 B2)
| sam_rec: forall E A B L,
    (forall X Y,
        X \notin L -> Y \notin {{X}} \u L ->
        sub_amber ((X,Y)::E) (open_tt A X) (open_tt B Y)) ->
    sub_amber E (typ_mu A) (typ_mu B)
| sam_refl: forall E A,
    wfe_amber E ->
    wf_amber E (typ_mu A) ->
    sub_amber E (typ_mu A) (typ_mu A).

(** Positive restriction *)
Inductive posvar: Mode -> atom -> typ -> typ -> Prop :=
| pos_nat: forall X m,
    posvar m X typ_nat typ_nat
| pos_top: forall X A m,
    type A ->
    posvar m X A typ_top
| pos_top_flip: forall X A m,
    type A ->
    posvar m X typ_top A
| pos_fvar_x: forall X,
    posvar Pos X (typ_fvar X) (typ_fvar X)
| pos_fvar_y: forall X Y m,
    X <> Y ->
    posvar m X (typ_fvar Y) (typ_fvar Y)
| pos_arrow: forall X m A1 A2 B1 B2,
    posvar (flip m) X B1 A1 ->
    posvar m X A2 B2 ->
    posvar m X (typ_arrow A1 A2) (typ_arrow B1 B2)
| pos_rec: forall X m A B L,
    (forall Y, Y \notin L \u {{X}} ->
               posvar m X (open_tt A Y) (open_tt B Y)) ->
     (forall Y, Y \notin L \u {{X}} ->
               posvar Pos Y (open_tt A Y) (open_tt B Y)) -> 
    posvar m X (typ_mu A) (typ_mu B)
| pos_rec_t : forall A X m L,
    X \notin fv_tt A ->
    (forall Y, Y \notin L \u {{X}} ->
               type (open_tt A Y)) ->
    posvar m X (typ_mu A) (typ_mu A).

(** Positive subtyping *)
Inductive sub_amber2: env -> typ -> typ -> Prop :=
| sam2_nat: forall E,
    wf_env E ->
    sub_amber2 E typ_nat typ_nat
| sam2_top: forall E A,
    WF E A ->
    wf_env E ->
    sub_amber2 E A typ_top
| sam2_fvar: forall E X ,
    binds X bind_sub E ->
    wf_env E ->
    sub_amber2 E (typ_fvar X) (typ_fvar X)
| sam2_arrow: forall E A1 A2 B1 B2,
    sub_amber2 E B1 A1 ->
    sub_amber2 E A2 B2 ->
    sub_amber2 E (typ_arrow A1 A2) (typ_arrow B1 B2)
| sam2_rec: forall E A B L,
    (forall X , X \notin L -> 
                sub_amber2 (X ~ bind_sub ++ E) (open_tt A X) (open_tt B X)) ->
    (forall X , X \notin L ->
                posvar Pos X (typ_mu A) (typ_mu B)) ->
    sub_amber2 E (typ_mu A) (typ_mu B)
| sam2_refl: forall E A,
    wf_env E ->
    WF E (typ_mu A) ->
    sub_amber2 E (typ_mu A) (typ_mu A).


Ltac gather_atoms ::=
  let A := gather_atoms_with (fun x : atoms => x) in
  let B := gather_atoms_with (fun x : atom => singleton x) in
  let E := gather_atoms_with (fun x : typ => fv_tt x) in
  let C := gather_atoms_with (fun x : list (var * typ) => dom x) in
  let D := gather_atoms_with (fun x : exp => fv_exp x) in
  let F := gather_atoms_with (fun x : env => dom x) in
  let G := gather_atoms_with (fun x : env_amber => domA x) in
  constr:(A `union` B `union`  E \u C \u D \u F \u G).

Hint Constructors wfe_amber wf_amber sub_amber sub_amber2 posvar  : core.

Lemma in_domA_1: forall X Y E,
    In (X, Y) E -> X \in domA E.
Proof with auto.
  intros.
  induction E...
  inversion H...
  destruct a.
  inversion H.
  inversion H0.
  subst.
  simpl...
  apply IHE in H0.
  simpl...
Qed.


Lemma in_domA_2: forall X Y E,
    In (X, Y) E -> Y \in domA E.
Proof with auto.
  intros.
  induction E...
  inversion H...
  destruct a.
  inversion H.
  inversion H0.
  subst.
  simpl...
  apply IHE in H0.
  simpl...
Qed.

Lemma notin_domA: forall E1 E2 X,
    X \notin domA (E1 ++ E2) -> X \notin domA E1 /\ X \notin domA E2.
Proof with auto.
  induction E1...
  intros.
  rewrite_alist (a :: (E1 ++ E2)) in H.
  destruct a.
  simpl in *...
  apply notin_union in H.
  destruct H.
  apply notin_union in H0.
  destruct H0.
  apply IHE1 in H1.
  destruct H1...
Qed.
  

Lemma wfe_amber_div: forall E1 E2,
    wfe_amber (E1 ++ E2) -> wfe_amber E1 /\ wfe_amber E2.
Proof with auto.
  induction E1...
  intros.
  rewrite_alist (a :: (E1 ++ E2)) in H.
  dependent destruction H.
  apply IHE1 in H1.
  destruct H1...
  split...
  apply notin_domA in H.
  constructor...
  apply notin_union in H0.
  destruct H0.
  apply notin_domA in H3...
Qed.  
  

Lemma wf_amber_comm: forall X Y A E1 E2,
    wf_amber (E1 ++ [(X, Y)] ++ E2) A -> wf_amber (E1 ++ [(X, Y)] ++ E2) (subst_tt X Y A).
Proof with auto.
  intros.
  dependent induction H;simpl...
  -
    destruct (X0==X)...
    subst.
    apply wfa_fvarr with (X:=X)...
    apply In_lemmaR...
    apply in_eq...
    apply in_app_iff in H.
    destruct H.
    apply wfa_fvarl with (Y:=Y0)...
    apply In_lemmaL...
    apply in_app_iff in H.
    destruct H.
    inversion H...
    inversion H1;subst...
    destruct n...
    inversion H1...
    apply wfa_fvarl with (Y:=Y0)...
    rewrite_alist ((E1 ++ [(X, Y)]) ++ E2).
    apply In_lemmaR...    
  -
    destruct (Y0==X)...
    subst.
    apply wfa_fvarr with (X:=X)...
    apply In_lemmaR...
    apply in_eq...
    apply in_app_iff in H.
    destruct H.
    apply wfa_fvarr with (X:=X0)...
    apply In_lemmaL...
    apply in_app_iff in H.
    destruct H.
    apply wfa_fvarr with (X:=X0)...
    inversion H...
    inversion H1;subst...
    apply In_lemmaR...
    apply in_eq...
    inversion H1...
    apply wfa_fvarr with (X:=X0)...
    rewrite_alist ((E1 ++ [(X, Y)]) ++ E2).
    apply In_lemmaR...
  -
    constructor...
    apply IHwf_amber1...
    apply IHwf_amber2...
  -
    apply wfa_rec with (L:=L \u {{X}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_alist (([(X0, Y0)] ++ E1) ++ [(X, Y)] ++ E2)...
    eapply H0...
Qed.

Lemma wf_amber_comm2: forall X Y A E1 E2,
    wf_amber (E1 ++ [(X, Y)] ++ E2) A -> wf_amber (E1 ++ [(X, Y)] ++ E2) (subst_tt Y X A).
Proof with auto.
  intros.
  dependent induction H;simpl...
  -
    destruct (X0==Y)...
    subst.
    apply wfa_fvarl with (Y:=Y)...
    apply In_lemmaR...
    apply in_eq...
    apply in_app_iff in H.
    destruct H.
    apply wfa_fvarl with (Y:=Y0)...
    apply In_lemmaL...
    apply in_app_iff in H.
    destruct H.
    inversion H...
    inversion H1;subst...
    apply wfa_fvarl with (Y:=Y0)...
    apply In_lemmaR.
    apply in_eq...
    inversion H1...
    apply wfa_fvarl with (Y:=Y0)...
    rewrite_alist ((E1 ++ [(X, Y)]) ++ E2).
    apply In_lemmaR...    
  -
    destruct (Y0==Y)...
    subst.
    apply wfa_fvarl with (Y:=Y)...
    apply In_lemmaR...
    apply in_eq...
    apply in_app_iff in H.
    destruct H.
    apply wfa_fvarr with (X:=X0)...
    apply In_lemmaL...
    apply in_app_iff in H.
    destruct H.
    inversion H...
    inversion H1;subst...
    destruct n...
    inversion H1...
    apply wfa_fvarr with (X:=X0)...
    rewrite_alist ((E1 ++ [(X, Y)]) ++ E2).
    apply In_lemmaR...
  -
    constructor...
    apply IHwf_amber1...
    apply IHwf_amber2...
  -
    apply wfa_rec with (L:=L \u {{Y}})...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite_alist (([(X0, Y0)] ++ E1) ++ [(X, Y)] ++ E2)...
    eapply H0...
Qed.    

Lemma suba_regular : forall E A B,
    sub_amber E A B -> wfe_amber E /\ wf_amber E A /\ wf_amber E B.
Proof with eauto.
  intros.
  induction H...
  -
    destruct IHsub_amber1.
    destruct H2.
    destruct IHsub_amber2.
    destruct H5.
    repeat split;auto...
  -
    split.
    pick fresh X.
    pick fresh Y.
    assert (X \notin L) by auto.
    assert (Y `notin` union (singleton X) L ) by auto.
    specialize (H0 X Y H1 H2).
    destruct H0.
    inversion H0...
    split;apply wfa_rec with (L:=L \u fv_tt B);intros.
    eapply H0...
    rewrite subst_tt_intro with (X:=Y)...
    rewrite_alist (nil ++ [(X, Y)] ++ E).
    apply wf_amber_comm2...
    eapply H0...
Qed.

Lemma suba2_regular : forall E A B,
    sub_amber2 E A B -> wf_env E /\ WF E A /\ WF E B.
Proof with eauto.
  intros.
  induction H...
  -
    destruct IHsub_amber2_1.
    destruct H2.
    destruct IHsub_amber2_2.
    destruct H5.
    repeat split...
  -
    split.
    pick fresh X.
    assert (X \notin L) by auto.
    specialize (H0 X  H2).
    destruct H0...
    inversion H0...
    split;apply WF_rec with (L:=L \u fv_tt A \u fv_tt B);intros;eapply H0...
Qed.

(** Translation of environments and types from the Amber rules *)
Fixpoint env_trans (E : env_amber) : env :=
  match E with
  | nil => nil
  | (X,Y)::E' => X ~ bind_sub ++  env_trans E'
  end.

Fixpoint rename_env (E : env_amber) (A : typ) : typ :=
  match E with
  | nil => A
  | cons (X,Y) E' => subst_tt Y (typ_fvar X) (rename_env E' A)
  end.

Lemma rename_top : forall E, rename_env E typ_top = typ_top.
  induction E; simpl in *; eauto.
  destruct a. 
  rewrite IHE.
  simpl in *; eauto.
Defined.

Lemma rename_nat : forall E, rename_env E typ_nat = typ_nat.
  induction E; simpl in *; eauto.
  destruct a.
  rewrite IHE.
  simpl in *; eauto.
Defined.

Lemma wfe_rename_fix:forall E Y,
    Y \notin domA E -> rename_env E Y = Y.
Proof with auto.
  intros.
  induction E...
  destruct a.
  simpl.
  rewrite_alist ([(a,a0)] ++ E) in H.
  apply notin_domA in H.
  destruct H...
  apply IHE in H0.
  rewrite H0.
  simpl in H...
  rewrite <- subst_tt_fresh...
Qed.
  
Lemma rename_fvar : forall E X Y,
    wfe_amber E ->
    In (X, Y) E -> rename_env E (typ_fvar Y) = typ_fvar X.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0.
  rewrite H0 in H.
  generalize dependent E.
  induction x;intros...
  -
    simpl in *...
    inversion H;subst.
    rewrite wfe_rename_fix with (E:=x0)...
    simpl...
    destruct (Y==Y)...
    destruct n...
  -
    simpl in *...
    destruct a.
    rewrite_alist ((a, a0) :: (x ++ (X, Y) :: x0)) in H.
    inversion H;subst.
    assert (x ++ (X, Y) :: x0 = x ++ (X, Y) :: x0) by auto.
    specialize (IHx H6 (x ++ (X, Y) :: x0) H0).
    clear H0.
    rewrite IHx.
    rewrite <- subst_tt_fresh...
    simpl in *...
    apply notin_union in H5.
    destruct H5.
    apply notin_domA in H1.
    destruct H1.
    simpl in H2...
Qed.

Lemma rename_fvar2 : forall E X Y,
    wfe_amber E ->
    In (X, Y) E -> rename_env E (typ_fvar X) = typ_fvar X.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0.
  rewrite H0 in H.
  generalize dependent E.
  induction x;intros...
  -
    simpl in *...
    inversion H;subst.
    rewrite wfe_rename_fix with (E:=x0)...
    simpl...
    destruct (X==Y)...
  -
    simpl in *...
    destruct a.
    rewrite_alist ((a, a0) :: (x ++ (X, Y) :: x0)) in H.
    inversion H;subst.
    assert (x ++ (X, Y) :: x0 = x ++ (X, Y) :: x0) by auto.
    specialize (IHx H6 (x ++ (X, Y) :: x0) H0).
    clear H0.
    rewrite IHx.
    rewrite <- subst_tt_fresh...
    simpl in *...
    apply notin_union in H5.
    destruct H5.
    apply notin_domA in H1.
    destruct H1.
    simpl in H2...
Qed.

Lemma rename_arrow : forall E A B, rename_env E (typ_arrow A B) = typ_arrow (rename_env E A) (rename_env E B).
  induction E; simpl in *; intros; eauto.
  destruct a. 
  rewrite IHE.
  simpl in *; eauto.
Defined.

Lemma rename_mu : forall E A, rename_env E (typ_mu A) = typ_mu (rename_env E A).
  induction E; simpl in *; intros; eauto.
  destruct a.
  rewrite IHE.
  simpl in *; eauto.
Defined.


Lemma domA_X_neq_Y: forall E X Y,
    wfe_amber E -> In (X, Y) E -> X <> Y.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0 in H.
  apply wfe_amber_div in H.
  destruct H.
  dependent destruction H1...
Qed.

Lemma rename_bvar : forall E n, rename_env E (typ_bvar n) = typ_bvar n.
  induction E; simpl in *; intros; eauto.
  destruct a. 
  rewrite IHE.
  simpl in *; eauto.
Defined.

Lemma subst_tt_open_tt_var2 : forall (X Y:atom) P T k,
  Y <> X ->
  type P ->
  open_tt_rec k Y (subst_tt X P T) = subst_tt X P (open_tt_rec k Y T).
Proof with congruence || auto.
  intros X Y P T k Neq Wu.
  rewrite subst_tt_open_tt_rec...
  simpl.
  destruct (Y == X)...
Qed.

Lemma rename_open: forall E A X,
    X \notin domA E ->
    rename_env E (open_tt A X) = open_tt (rename_env E A) X.
Proof with auto.
  intros.
  unfold open_tt.
  generalize 0.
  induction A;intros;simpl...
  -
    rewrite rename_top...
  -
    rewrite rename_nat...
  -
    destruct (n0==n)...
    subst.
    rewrite rename_bvar...
    simpl...
    destruct (n==n)...
    rewrite wfe_rename_fix...
    destruct n0...
    rewrite rename_bvar...
    simpl...
    destruct (n0==n)...
    destruct n1...
  -
    induction E...
    rewrite_alist ([(a0)] ++ E) in H.
    apply notin_domA in H.
    destruct H.
    apply IHE in H0.
    simpl...
    destruct a0.
    rewrite subst_tt_open_tt_var2...
    f_equal...
    simpl in H...
  -
    rewrite rename_mu...
    rewrite IHA with (n:=S n)...
    rewrite rename_mu...
  -
    rewrite rename_arrow...
    rewrite IHA1 with (n:=n)...
    rewrite IHA2 with (n:=n)...
    rewrite rename_arrow...
Qed.

Lemma rename_subst: forall E (X Y:atom) A,
    X \notin domA E \u fv_tt (rename_env E A)->
    Y \notin domA E ->
    (subst_tt X Y (rename_env E (open_tt A X))) = rename_env E (open_tt A Y).
Proof with auto.
  intros.
  rewrite rename_open...
  rewrite <- subst_tt_intro...
  rewrite rename_open...
Qed.

Lemma notin_fv_domA: forall E A X,
    X \notin domA E ->
    X \notin fv_tt A ->
    X \notin fv_tt (rename_env E A).
Proof with auto.
  intros.
  induction E...
  simpl...
  destruct a.
  rewrite_alist ([(a, a0)] ++ E) in H.
  apply notin_domA in H.
  destruct H.
  simpl in H...
  apply notin_fv_subst...
Qed.

Lemma domA_neq_mutual_aux: forall E1 X Y S T E2 E3,
    wfe_amber (E1 ++ [(X,Y)] ++ E2 ++ [(S,T)] ++ E3) ->
    Y <> S /\ X <> T /\ X <> S /\ Y <> T.
Proof with auto.
  induction E1;intros...
  -
    simpl in H.
    dependent destruction H.
    apply notin_union in H0.
    destruct H0.
    apply notin_domA in H2.
    destruct H2.
    apply notin_domA in H.
    destruct H.
    simpl in *...
  -
    rewrite_alist ([a] ++ (E1 ++ [(X, Y)] ++ E2 ++ [(S, T)] ++ E3)) in H.
    apply wfe_amber_div in H.
    destruct H...
    eapply IHE1...
    eassumption...
Qed.
  
Lemma domA_neq_mutual: forall X Y S T E,
    wfe_amber E ->
    In (X, Y) E ->
    In (S, T) E ->
    X <> S ->
    S <> Y.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0 in H1.
  rewrite H0 in H.
  apply in_app_iff in H1.
  destruct H1.
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x1 ++ [(S, T)] ++ x2 ++ [(X, Y)] ++ x0) in H.
  apply domA_neq_mutual_aux in H...
  apply in_inv in H1.
  destruct H1.
  inversion H1...
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x ++ [(X, Y)] ++ x1 ++ [(S, T)] ++ x2) in H.
  apply domA_neq_mutual_aux in H...
  destruct H...
Qed.

Lemma domA_neq_mutual1: forall X Y S T E,
    wfe_amber E ->
    In (X, Y) E ->
    In (S, T) E ->
    Y <> T ->
    X <> S.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0 in H1.
  rewrite H0 in H.
  apply in_app_iff in H1.
  destruct H1.
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x1 ++ [(S, T)] ++ x2 ++ [(X, Y)] ++ x0) in H.
  apply domA_neq_mutual_aux in H...
  destruct H.
  destruct H3.
  destruct H4...
  apply in_inv in H1.
  destruct H1.
  inversion H1...
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x ++ [(X, Y)] ++ x1 ++ [(S, T)] ++ x2) in H.
  apply domA_neq_mutual_aux in H...
Qed.

Lemma domA_neq_mutual2: forall X Y S T E,
    wfe_amber E ->
    In (X, Y) E ->
    In (S, T) E ->
    X <> S ->
    T <> Y.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0 in H1.
  rewrite H0 in H.
  apply in_app_iff in H1.
  destruct H1.
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x1 ++ [(S, T)] ++ x2 ++ [(X, Y)] ++ x0) in H.
  apply domA_neq_mutual_aux in H...
  apply in_inv in H1.
  destruct H1.
  inversion H1...
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x ++ [(X, Y)] ++ x1 ++ [(S, T)] ++ x2) in H.
  apply domA_neq_mutual_aux in H...
  destruct H...
  destruct H3.
  destruct H4...
Qed.

Lemma notin_subst_Y:forall A Y B,
    Y \notin fv_tt B  ->
    Y \notin fv_tt (subst_tt Y B A).
Proof with auto.
  induction A...
  intros.
  simpl.
  destruct (a==Y)...
Qed.  

  
Lemma raname_notin_Y: forall E X Y A,
    wfe_amber E ->
    In (X,Y) E ->
    Y \notin fv_tt (rename_env E A).
Proof with auto.
  induction E...
  intros.
  destruct a.
  rewrite_alist ([(a, a0)] ++ E) in H0.
  apply in_app_iff in H0.
  dependent destruction H.
  destruct H2...
  -
    inversion H2...
    inversion H3;subst...
    simpl.
    apply notin_subst_Y...
  -
    simpl.
    apply notin_fv_subst...
    apply in_domA_2 in H2.
    assert (Y <> a).
    apply in_notin with (T:=domA E)...
    simpl...
    apply IHE with (X:=X)...
    apply in_domA_2 in H2.
    apply in_notin with (T:=domA E)...
Qed.

Lemma domA_neq_mutual_false: forall E1 X Y Z E2 E3,
    wfe_amber (E1 ++ [(X,Y)] ++ E2 ++ [(X,Z)] ++ E3) -> False.
Proof with auto.
  induction E1;intros...
  -
    simpl in H.
    dependent destruction H.
    apply notin_domA in H.
    destruct H.
    simpl in H2...
  -
    rewrite_alist ([a] ++ (E1 ++ [(X, Y)] ++ E2 ++ [(X, Z)] ++ E3)) in H.
    apply wfe_amber_div in H.
    destruct H...
    eapply IHE1...
    eassumption...
Qed.    
  
Lemma domA_neq_mutual3: forall X Y Z E,
    wfe_amber E ->
    In (X, Y) E ->
    In (X, Z) E ->
    Y = Z.
Proof with auto.
  intros.
  apply in_split in H0.
  destruct H0.
  destruct H0.
  rewrite H0 in H1.
  rewrite H0 in H.
  apply in_app_iff in H1.
  destruct H1.
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x1 ++ [(X, Z)] ++ x2 ++ [(X, Y)] ++ x0) in H.
  apply domA_neq_mutual_false in H...
  destruct H.
  apply in_inv in H1.
  destruct H1.
  inversion H1...
  apply in_split in H1.
  destruct H1.
  destruct H1.
  rewrite H1 in H.
  rewrite_alist (x ++ [(X, Y)] ++ x1 ++ [(X, Z)] ++ x2) in H.
  apply domA_neq_mutual_false in H...
  destruct H...
Qed.

Lemma notin_env_trans: forall E X,
    X \notin domA E ->
    X \notin dom (env_trans E).
Proof with auto.
  induction E...
  intros.
  destruct a.
  simpl in *...
Qed.  

Lemma env_trans_wfe: forall E,
    wfe_amber E ->
    wf_env (env_trans E).
Proof with auto.
  induction E...
  intros.
  destruct a.
  simpl.
  dependent destruction H.
  constructor...
  apply notin_env_trans...
Qed.

Lemma fvar_in_env_trans_X: forall E X Y,
    In (X, Y) E ->
    In (X,bind_sub) (env_trans E).
Proof with auto.
  induction E...
  intros.
  destruct a.
  simpl in *...
  destruct H...
  inversion H;subst...
  right...
  apply IHE with (Y:=Y)...
Qed.


Lemma wf_amber_to_WF: forall E A,
    wf_amber E A ->
    WF (env_trans E) (rename_env E A).
Proof with auto.
  intros.
  induction H...
  -
    rewrite rename_nat...
  -
    rewrite rename_top...
  -
    rewrite rename_fvar2 with (Y:=Y)...
    constructor...
    apply fvar_in_env_trans_X in H...
  -
    rewrite rename_fvar with (X:=X)...
    constructor...
    apply fvar_in_env_trans_X in H...
  -
    rewrite rename_arrow...
  -
    rewrite rename_mu...
    apply WF_rec with (L:=L \u fv_tt A \u domA E)...
    intros.
    pick fresh Y.
    assert (X \notin L) by auto.
    assert (Y \notin L \u {{X}}) by auto.
    specialize (H0 _ _ H2 H3).
    simpl in H0.
    rewrite <- subst_tt_fresh in H0...
    rewrite rename_open in H0...
    apply notin_fv_domA...
    apply notin_fv_tt_open_aux...
Qed.          
    
Lemma posvar_self_notin: forall A m X ,
    type A ->
    X \notin fv_tt A ->
    posvar m X A A.
Proof with auto.
  intros.
  generalize dependent m.
  induction H;intros...
  -
    simpl in H0.
    constructor...
  -
    simpl in H0.
    apply notin_union in H0.
    destruct H0.
    constructor...
  -
    simpl in *.
    apply pos_rec_t with (L:=L \u fv_tt T)...
Qed.

Lemma rename_env_open: forall A X Y,
    X <> Y ->
    X `notin` fv_tt (open_tt A Y) ->
    X \notin fv_tt A.
Proof with auto.
  unfold open_tt.
  intros A.
  generalize 0.
  induction A;intros;simpl in *...
  -
    apply IHA with (n:=S n) (Y:=Y)...
  -
    apply notin_union in H0.
    destruct H0.
    apply notin_union...
    split...
    eapply IHA1...
    eapply IHA2...
Qed.    

Lemma rename_notin_X: forall E X Y A,
    wfe_amber E ->
    In (X,Y) E ->
    wf_amber E A ->
    Y \notin fv_tt A ->
    X \notin fv_tt A ->
    X \notin fv_tt (rename_env E A).
Proof with auto.
  intros.
  induction H1...
  -
    rewrite rename_nat...
  -
    rewrite rename_top...
  -
    rewrite rename_fvar2 with (Y:=Y0)...
  -
    rewrite rename_fvar with (X:=X0)...
    simpl in *.
    apply notin_singleton_2.
    eapply domA_neq_mutual1...
    eassumption.
    eassumption.
    eassumption.
  -
    rewrite rename_arrow...
    simpl in *.
    apply notin_union in H2.
    apply notin_union in H3.
    destruct H2.
    destruct H3.
    apply notin_union...
  -
    rewrite rename_mu...
    simpl in *.
    pick fresh X0.
    pick fresh Y0.
    assert (X0 \notin L) by auto.
    assert (Y0 \notin L \u {{X0}}) by auto.
    assert (wfe_amber ((X0, Y0) :: E)).
    constructor...
    assert ((X0, Y0) = (X, Y) \/ In (X, Y) E ).
    right...
    assert (Y `notin` fv_tt (open_tt A X0)).
    apply notin_fv_tt_open_aux...
    assert (X `notin` fv_tt (open_tt A X0)).
    apply notin_fv_tt_open_aux...
    specialize (H4 _ _ H5 H6 H7 H8 H9 H10).
    rewrite <- subst_tt_fresh in H4...
    rewrite rename_open in H4.
    apply rename_env_open with (Y:=X0)...
    auto.
    apply notin_fv_domA...
    apply notin_fv_tt_open_aux...
Qed.

  
Lemma sub_amber_to_posvar_aux: forall E A B,
    sub_amber E A B ->
    forall X Y , 
    In (X,Y) E ->
      (
        Y \notin fv_tt A ->
        X \notin fv_tt B ->
        posvar  Pos X (rename_env E A) (rename_env E B)
       )  /\ (
        X \notin fv_tt A ->
        Y \notin fv_tt B -> 
        posvar  Neg X (rename_env E A) (rename_env E B)
      ).
Proof with auto.  
  intros E A B H.
  dependent induction H;intros...
  -
    split;intros.
    rewrite rename_nat...
    rewrite rename_nat...
  -
    split;intros.
    rewrite rename_top...
    constructor...
    apply wf_amber_to_WF in H.
    apply soundness_wf in H.
    apply wfs_type in H...
    rewrite rename_top...
    constructor...
    apply wf_amber_to_WF in H.
    apply soundness_wf in H.
    apply wfs_type in H...
  -
    split;intros.
    +
      assert (rename_env E X = X).
      eapply rename_fvar2...
      eassumption.
      rewrite H4.
      assert (rename_env E Y = X).
      eapply rename_fvar...
      rewrite H5.
      simpl in H2...
      destruct (X0==X).
      subst...
      constructor...
    +
      assert (rename_env E X = X).
      eapply rename_fvar2...
      eassumption.
      rewrite H4.
      assert (rename_env E Y = X).
      eapply rename_fvar...
      rewrite H5.
      simpl in H2...
  -
    split;intros.
    simpl in *.
    rewrite rename_arrow...
    rewrite rename_arrow...
    constructor...
    simpl.
    eapply IHsub_amber1...
    assumption.
    eapply IHsub_amber2...
    assumption.
    simpl in *.
    rewrite rename_arrow...
    rewrite rename_arrow...
    constructor...
    simpl.
    eapply IHsub_amber1...
    assumption.
    eapply IHsub_amber2...
    assumption.
  -
    split;intros.
    +
      rewrite rename_mu...
      rewrite rename_mu...
      simpl in H2.
      simpl in H3.
      apply pos_rec with (L:=L \u {{X}} \u {{Y}} \u domA E \u fv_tt A \u fv_tt B)...
      *
        intros.
        pick fresh X0.
        assert (Y0 \notin L) by auto.
        assert (X0 `notin` union (singleton Y0) L) by auto.
        specialize (H0 _ _ H5 H6).
        assert (In (X, Y) ((Y0, X0) :: E)).
        {
          rewrite_alist ([(Y0, X0)] ++ E).
          apply In_lemmaR...
        }        
        assert (Y `notin` fv_tt (open_tt A Y0)).
        {
          apply notin_fv_tt_open_aux...
        }
        assert (X `notin` fv_tt (open_tt B X0)).
        {
          apply notin_fv_tt_open_aux...
        }
        specialize (H0 _ _ H7).
        destruct H0.
        specialize (H0 H8 H9).
        simpl in H0.
        rewrite <- subst_tt_fresh in H0...
        rewrite <- rename_open...
        rewrite rename_subst in H0...
        rewrite <- rename_open...
        apply notin_union...
        split...
        apply notin_fv_domA...
        apply notin_fv_domA...
        apply notin_fv_tt_open_aux...
      *
        intros.
        pick fresh X0.
        assert (Y0 \notin L) by auto.
        assert (X0 `notin` union (singleton Y0) L) by auto.
        specialize (H0 _ _ H5 H6).
        assert (In (Y0, X0) ((Y0, X0) :: E)).
        {
          apply in_eq...
        }
        specialize (H0 _ _ H7).
        assert (X0 `notin` fv_tt (open_tt A Y0)).
        {
          apply notin_fv_tt_open_aux...
        }
        assert (Y0 `notin` fv_tt (open_tt B X0)).
        {
          apply notin_fv_tt_open_aux...
        }
        destruct H0.
        specialize (H0 H8 H9).
        simpl in H0.
        rewrite <- subst_tt_fresh in H0...
        rewrite <- rename_open...
        rewrite rename_subst in H0...
        rewrite <- rename_open...
        apply notin_union...
        split...
        apply notin_fv_domA...
        apply notin_fv_domA...
    +
      rewrite rename_mu...
      rewrite rename_mu...
      simpl in H2.
      simpl in H3.
      apply pos_rec with (L:=L \u {{X}} \u {{Y}} \u domA E \u fv_tt A \u fv_tt B)...
      *
        intros.
        pick fresh X0.
        assert (Y0 \notin L) by auto.
        assert (X0 `notin` union (singleton Y0) L) by auto.
        specialize (H0 _ _ H5 H6).
        assert (In (X, Y) ((Y0, X0) :: E)).
        {
          rewrite_alist ([(Y0, X0)] ++ E).
          apply In_lemmaR...
        }        
        assert (X `notin` fv_tt (open_tt A Y0)).
        {
          apply notin_fv_tt_open_aux...
        }
        assert (Y `notin` fv_tt (open_tt B X0)).
        {
          apply notin_fv_tt_open_aux...
        }
        specialize (H0 _ _ H7).
        destruct H0.
        specialize (H10 H8 H9).
        simpl in H10.
        rewrite <- subst_tt_fresh in H10...
        rewrite <- rename_open...
        rewrite rename_subst in H10...
        rewrite <- rename_open...
        apply notin_union...
        split...
        apply notin_fv_domA...
        apply notin_fv_domA...
        apply notin_fv_tt_open_aux...
      *
        intros.
        pick fresh X0.
        assert (Y0 \notin L) by auto.
        assert (X0 `notin` union (singleton Y0) L) by auto.
        specialize (H0 _ _ H5 H6).
        assert (In (Y0, X0) ((Y0, X0) :: E)).
        {
          apply in_eq...
        }
        specialize (H0 _ _ H7).
        assert (X0 `notin` fv_tt (open_tt A Y0)).
        {
          apply notin_fv_tt_open_aux...
        }
        assert (Y0 `notin` fv_tt (open_tt B X0)).
        {
          apply notin_fv_tt_open_aux...
        }
        destruct H0.
        specialize (H0 H8 H9).
        simpl in H0.
        rewrite <- subst_tt_fresh in H0...
        rewrite <- rename_open...
        rewrite rename_subst in H0...
        rewrite <- rename_open...
        apply notin_union...
        split...
        apply notin_fv_domA...
        apply notin_fv_domA...
  -
    split;intros.
    apply posvar_self_notin...
    apply wf_amber_to_WF in H0...
    apply soundness_wf in H0.
    apply wfs_type in H0...
    apply rename_notin_X with (Y:=Y)...
    simpl in *.
    apply posvar_self_notin...
    apply wf_amber_to_WF in H0...
    apply soundness_wf in H0.
    apply wfs_type in H0...
    apply rename_notin_X with (Y:=Y)...
Qed.

Lemma posvar_regular: forall m X A B,
    posvar m X A B ->
    type A /\ type B.
Proof with auto.
  intros.
  induction H...
  -
    destruct IHposvar1.
    destruct IHposvar2...
  -
    split.
    apply type_mu with (L:=L \u {{X}})...
    intros.
    eapply H0...
    apply type_mu with (L:=L \u {{X}})...
    intros.
    eapply H0...
  -
    split.
    apply type_mu with (L:=L \u {{X}})...
    apply type_mu with (L:=L \u {{X}})...
Qed.
    

Lemma pos_rename_fix : forall X Y Z A B m,
    posvar m X A B ->
    X \notin {{Y}} \u {{Z}} ->
    posvar m X (subst_tt Y Z A) (subst_tt Y Z B).
Proof with auto.
  intros.
  induction H...
  -
    simpl in *...
    destruct (X==Y)...
    constructor...
    apply subst_tt_type...
    constructor...
    apply subst_tt_type...
  -
    simpl in *.
    constructor...
    apply subst_tt_type...
  -
    simpl.
    destruct (X==Y)...
  -
    simpl in *...
    destruct (Y0==Y)...
  -
    simpl in *...
  -
    simpl in *...
    apply pos_rec with (L:=L \u {{Y}} \u {{X}} \u {{Z}}).
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
  -
    simpl in *.
    apply pos_rec_t with (L:=L \u {{X}} \u {{Y}}).
    apply notin_fv_subst...
    intros.
    rewrite subst_tt_open_tt_var...
    apply subst_tt_type...
Qed.
    
  
Lemma pos_rename_1: forall X m A B Y,
    posvar m X A B ->
    Y \notin {{X}} \u fv_tt A \u fv_tt B ->
    posvar m Y (subst_tt X Y A) (subst_tt X Y B).
Proof with auto.
  intros.
  generalize dependent Y.
  induction H;intros...
  -
    constructor...
    apply subst_tt_type...
  -
    constructor...
    apply subst_tt_type...
  -
    simpl in *...
    destruct (X==X)...
  -
    simpl in *...
    destruct (Y==X)...
  -
    simpl in *...
  -
    simpl in *...
    apply pos_rec with (L:=L \u {{X}} \u {{Y}} \u fv_tt A \u fv_tt B).
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
    apply H0...
    apply notin_union...
    split...
    apply notin_union...
    split...
    apply notin_fv_tt_open_aux... 
    apply notin_fv_tt_open_aux...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
    pick fresh Y1.
    assert (Y1 `notin` union L (singleton X) ) by auto.
    assert (Y0 `notin` union (singleton Y1) (union (fv_tt (open_tt A Y1)) (fv_tt (open_tt B Y1)))).
    {
      apply notin_union.
      split...
      apply notin_union.
      split;apply notin_fv_tt_open_aux...
    }    
    specialize (H2 _ H5 _ H6).
    rewrite <- subst_tt_intro in H2...
    rewrite <- subst_tt_intro in H2...
    apply pos_rename_fix...
  -
    simpl in *.
    apply pos_rec_t with (L:=L \u {{X}} \u {{Y}}).
    rewrite <- subst_tt_fresh...
    intros.
    rewrite subst_tt_open_tt_var...
    apply subst_tt_type...
Qed.

Lemma pos_rename_2: forall X m A B Y,
    posvar m X A B ->
    Y \notin {{X}} \u fv_tt A \u fv_tt B ->
    posvar m X (subst_tt X Y A) (subst_tt X Y B).
Proof with auto.
  intros.
  generalize dependent Y.
  induction H;intros...
  -
    constructor...
    apply subst_tt_type...
  -
    constructor...
    apply subst_tt_type...
  -
    simpl in *...
    destruct (X==X)...
  -
    simpl in *...
    destruct (Y==X)...
  -
    simpl in *...
  -
    simpl in *...
    apply pos_rec with (L:=L \u {{X}} \u {{Y}} \u fv_tt A \u fv_tt B).
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
    apply H0...
    apply notin_union...
    split...
    apply notin_union...
    split...
    apply notin_fv_tt_open_aux... 
    apply notin_fv_tt_open_aux...
    intros.
    rewrite subst_tt_open_tt_var...
    rewrite subst_tt_open_tt_var...
    pick fresh Y1.
    assert (Y1 `notin` union L (singleton X) ) by auto.
    assert (Y0 `notin` union (singleton Y1) (union (fv_tt (open_tt A Y1)) (fv_tt (open_tt B Y1)))).
    {
      apply notin_union.
      split...
      apply notin_union.
      split;apply notin_fv_tt_open_aux...
    }    
    specialize (H2 _ H5 _ H6).
    rewrite <- subst_tt_intro in H2...
    rewrite <- subst_tt_intro in H2...
    apply pos_rename_fix...
  -
    simpl in *.
    apply pos_rec_t with (L:=L \u {{X}} \u {{Y}}).
    rewrite <- subst_tt_fresh...
    intros.
    rewrite subst_tt_open_tt_var...
    apply subst_tt_type...
Qed.    
    
(** Lemma 25 *)
Lemma sub_amber_to_amber_2: forall E A B,
    sub_amber E A B ->
    sub_amber2 (env_trans E) (rename_env E A) (rename_env E B).
Proof with auto using notin_fv_domA, notin_fv_tt_open_aux.
  intros.
  induction H...
  -
    rewrite rename_nat...
    constructor...
    apply env_trans_wfe...
  -
    rewrite rename_top...
    constructor...
    apply wf_amber_to_WF...
    apply env_trans_wfe...
  -
    assert (rename_env E X = X).
    eapply rename_fvar2...
    eassumption.
    rewrite H1.
    assert (rename_env E Y = X).
    eapply rename_fvar...
    rewrite H2.
    constructor...
    apply fvar_in_env_trans_X in H...
    apply env_trans_wfe...
  -
    rewrite rename_arrow...
    rewrite rename_arrow...
  -
    rewrite rename_mu...
    rewrite rename_mu...
    apply sam2_rec with (L:=L \u domA E \u fv_tt A \u fv_tt B).
    +
      intros.
      simpl in H0.
      pick fresh Y.
      assert (X \notin L) as Hx by auto.
      assert (Y \notin {{X}} \u L) as Hy by auto.
      specialize (H0 _ _ Hx Hy).
      rewrite <- subst_tt_fresh in H0...
      rewrite rename_subst in H0...
      rewrite rename_open in H0...
      rewrite rename_open in H0...
    +
      intros.
      pick fresh Y.
      assert (X \notin L) as Hx by auto.
      assert (Y \notin {{X}} \u L) as Hy by auto.
      specialize (H _ _ Hx Hy).
      apply pos_rec with (L:=L \u domA E \u fv_tt A \u fv_tt B \u {{X}} \u {{Y}} ).
      *
        intros.
        apply sub_amber_to_posvar_aux with (X:=X) (Y:=Y) in H.
        destruct H.
        assert (Y `notin` fv_tt (open_tt A X)).
        apply notin_fv_tt_open_aux...
        assert (X `notin` fv_tt (open_tt B Y)).
        apply notin_fv_tt_open_aux...
        specialize (H H4 H5).
        simpl in H.
        rewrite <- subst_tt_fresh in H...
        rewrite rename_subst in H...
        rewrite rename_open in H...
        rewrite rename_open in H...
        rewrite subst_tt_intro with (X:=X)...
        remember (subst_tt X Y0 (open_tt (rename_env E A) X)).
        rewrite subst_tt_intro with (X:=X)...
        subst.
        apply pos_rename_2...
        apply in_eq...
      *
        intros.
        apply sub_amber_to_posvar_aux with (X:=X) (Y:=Y) in H.
        destruct H.
        assert (Y `notin` fv_tt (open_tt A X)).
        apply notin_fv_tt_open_aux...
        assert (X `notin` fv_tt (open_tt B Y)).
        apply notin_fv_tt_open_aux...
        specialize (H H4 H5).
        simpl in H.
        rewrite <- subst_tt_fresh in H...
        rewrite rename_subst in H...
        rewrite rename_open in H...
        rewrite rename_open in H...
        rewrite subst_tt_intro with (X:=X)...
        remember (subst_tt X Y0 (open_tt (rename_env E A) X)).
        rewrite subst_tt_intro with (X:=X)...
        subst.
        apply pos_rename_1...
        apply in_eq...
  -
    rewrite rename_mu...
    apply sam2_refl...
    apply env_trans_wfe...
    rewrite <- rename_mu.
    apply wf_amber_to_WF...
Qed.
