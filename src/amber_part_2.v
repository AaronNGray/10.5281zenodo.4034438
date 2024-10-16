Require Import Metalib.Metatheory.
Require Import Program.Equality.
Require Export amber_part_1.
Require Export decidability.


Definition mode_xor (m1 m2 : Mode) : Mode :=
  match m1 with
  | Pos => match m2 with
           | Pos => Pos
           | Neg => Neg
           end
  | Neg => match m2 with
           | Pos => Neg
           | Neg => Pos
           end
  end.

Lemma xor_prop_1: forall m,
    (mode_xor Pos m) = m.
Proof with auto.
  intros.
  destruct m...
Qed.

Lemma xor_prop_2: forall m,
    (mode_xor m Pos) = m.
Proof with auto.
  intros.
  destruct m...
Qed.

Lemma xor_prop_3: forall m1 m2,
    (mode_xor m1 m2) = mode_xor (flip m1) (flip m2).
Proof with auto.
  intros.
  destruct m1;destruct m2...
Qed.

Lemma xor_prop_4: forall m1 m2,
    flip (mode_xor m1 m2) = mode_xor (flip m1) ( m2).
Proof with auto.
  intros.
  destruct m1;destruct m2...
Qed.

Lemma pos_rename_3: forall X m n A B Y,
    posvar m X A B ->
    Y \notin {{X}} \u fv_tt A \u fv_tt B ->
    posvar n Y A B.
Proof with auto.
  intros.
  generalize dependent Y.
  generalize dependent n.
  induction H;intros...
  -
    simpl in *...
  -
    simpl in *...
  -
    simpl in *...
    apply pos_rec with (L:=L \u {{X}} \u {{Y}} \u fv_tt A \u fv_tt B).
    +
      intros.
      apply H2...
      apply notin_union...
      split...
      apply notin_union...
      split...
      apply notin_fv_tt_open_aux... 
      apply notin_fv_tt_open_aux...
    +
      intros.
      apply H1...
  -
    simpl in *.
    apply pos_rec_t with (L:=L \u {{X}} \u {{Y}})...
Qed.

Lemma posvar_comm: forall m A B X,
    posvar m X A B ->
    posvar m X B A.
Proof with auto.
  intros.
  induction H...
  -
    apply pos_rec with (L:=L)...
  -
    apply pos_rec_t with (L:=L)...
Qed.









Inductive typePairR : typ -> typ -> Prop :=
| tp_nat: 
    typePairR  typ_nat typ_nat
| tp_top: forall  A ,
    type A ->
    typePairR  A typ_top
| tp_top_flip: forall A ,
    type A ->
    typePairR  typ_top A
| tp_fvar_x: forall X,
    typePairR (typ_fvar X) (typ_fvar X)
| tp_arrow: forall  A1 A2 B1 B2,
    typePairR  B1 A1 ->
    typePairR  A2 B2 ->
    typePairR  (typ_arrow A1 A2) (typ_arrow B1 B2)
| tp_rec: forall  A B L,
    (forall X, X \notin L ->
               typePairR (open_tt A X) (open_tt B X)) ->
    typePairR (typ_mu A) (typ_mu B).

Hint Constructors typePairR : core.

Lemma posvar_calc_sign: forall A B,
    typePairR A B ->
    forall X m1 Y m2 m4 C D,
    posvar m1 X A B ->  
    posvar m2 Y A B ->
    posvar (mode_xor m1 m2) X C D ->
    posvar m4 Y C D ->
    X <> Y ->
    posvar m1 X (subst_tt Y C A) (subst_tt Y D B) /\
    posvar (mode_xor m2 m4) Y (subst_tt Y C A) (subst_tt Y D B).
Proof with auto.
  intros A B  H.
  dependent induction H;intros...
  -
    split.
    simpl...
    constructor...
    apply subst_tt_type...
    apply posvar_regular in H2...
    destruct H2...
    simpl...
    constructor...
    apply subst_tt_type...
    apply posvar_regular in H2...
    destruct H2...
  -
    split.
    simpl...
    constructor...
    apply subst_tt_type...
    apply posvar_regular in H2...
    destruct H2...
    simpl...
    constructor...
    apply subst_tt_type...
    apply posvar_regular in H2...
    destruct H2...
  -
    split.
    simpl.
    destruct (X==Y)...
    dependent destruction H...
    destruct H3...
    dependent destruction H0...
    rewrite xor_prop_2 in H1...
    destruct H0...
    simpl.
    destruct (X==Y)...
    dependent destruction H0...
    dependent destruction H...
    destruct H3...
    rewrite xor_prop_1...
    destruct H0...
  -
    dependent destruction H1...
    dependent destruction H2...
    simpl in *...
    split...
    +
      constructor...
      apply IHtypePairR1 with (m2:=flip m0) (m4:=m4)...
      rewrite <- xor_prop_3...
      apply posvar_comm...
      apply posvar_comm...
      apply IHtypePairR2 with (m2:=m0) (m4:=m4)...
    +
      constructor...
      rewrite xor_prop_4...
      apply IHtypePairR1 with (m1:=flip m) (X:=X)...
      rewrite <- xor_prop_3...
      apply posvar_comm...
      apply posvar_comm...
      apply IHtypePairR2 with (m1:=m) (X:=X)...
  -
    split.
    +
      simpl...
      assert (type C /\ type D).
      apply posvar_regular in H4...
      destruct H6.
      dependent destruction H2;dependent destruction H1.
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt A \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0...
          eassumption.
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0...
          eapply pos_rename_3...
          eassumption.
          eassumption.
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          apply pos_rename_3 with (X:=X0) (m:=m4)...
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
          apply pos_rename_3 with (X:=X0) (m:=m4)...
      *
        rewrite <- subst_tt_fresh...
        rewrite <- subst_tt_fresh...
        apply pos_rec_t with (L:=L0)...        
    +
      simpl...
      assert (type C /\ type D).
      apply posvar_regular in H4...
      destruct H6.
      dependent destruction H2;dependent destruction H1.
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt A \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0...
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0...
          eapply pos_rename_3...
          eassumption.
          eassumption.
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0 with (m2:=m0) (m4:=m4) (X0:=X) (m1:=m)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          apply pos_rename_3 with (X:=X0) (m:=m4)...
      *
        apply pos_rec with (L:=L \u L0 \u L1 \u {{X}} \u {{X0}}  \u fv_tt B \u fv_tt C \u fv_tt D).
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          eapply H0 with (m2:=m0) (m4:=m4) (X0:=X) (m1:=m)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
        --
          intros.
          rewrite subst_tt_open_tt_var...
          rewrite subst_tt_open_tt_var...
          apply H0 with (m2:=m0) (m4:=m4)...
          eapply posvar_self_notin...
          apply notin_fv_tt_open_aux... 
          apply pos_rename_3 with (X:=X0) (m:=m4)...
      *
        rewrite <- subst_tt_fresh...
        rewrite <- subst_tt_fresh...
        apply pos_rec_t with (L:=L1)...
Qed.        


Lemma typePairR_refl: forall A,
    type A ->
    typePairR A A.
Proof with auto.
  intros.
  induction H...
  apply tp_rec with (L:=L)...
Qed.  

Lemma posvar_typePairR : forall m A B X,
    posvar m X A B ->
    typePairR A B.
Proof with auto.
  intros.
  induction H...
  -
    apply tp_rec with (L:=L \u {{X}})...
  -
    apply typePairR_refl...
    apply type_mu with (L:=L \u {{X}})...
Qed.    
  
(** Lemma 23 *)
Lemma posvar_keeps_sign : forall X Y A B m,
    posvar Pos Y A B ->
    Y <> X ->
    posvar m X A B ->
    posvar m X (subst_tt Y A A) (subst_tt Y B B).
Proof with auto.
  intros.
  apply posvar_calc_sign with (Y:=Y) (m2:=Pos) (m4:=Pos) (C:=A) (D:=B) in H1...
  destruct H1...
  eapply posvar_typePairR...
  eassumption.
  rewrite xor_prop_2...
Qed.          



Lemma sub_single_implies_double1: forall E A B C D X,
      sub E A B ->
      posvar Pos X A B ->
      sub E C D ->
      sub E (subst_tt X C A) (subst_tt X D B)
with sub_single_implies_double2: forall E A B C D X,
      sub E B A ->
      posvar Neg X A B ->
      sub E C D ->
      sub E (subst_tt X D B) (subst_tt X C A).
Proof with auto.
  -
    intros.
    generalize dependent X.
    generalize dependent C.
    generalize dependent D.
    induction H;intros.
    +
      simpl.
      constructor...
    +
      simpl.
      destruct (X==X0).
      apply H1.
      apply completeness.
      apply refl...      
    +
      simpl.
      constructor...
      apply completeness_wf.
      apply subst_tt_wfs...
      apply soundness in H1.
      apply sub_regular in H1.
      destruct H1.
      destruct H3...
      apply soundness_wf...
    +
      dependent destruction H2.
      simpl in *.
      constructor.
      apply sub_single_implies_double2;try assumption.
      apply posvar_comm...
      apply IHsub2;try assumption.
    +
      dependent destruction H4.
      *
        assert (H6:=H3).
        apply soundness in H6.
        apply sub_regular in H6.
        destruct H6.
        destruct H7.
        apply wfs_type in H8.
        apply wfs_type in H7.
        simpl in *.
        apply sa_rec with (L:=L \u L0 \u {{X}} \u dom E \u fv_tt A1 \u fv_tt A2).
        intros.
        rewrite subst_tt_open_tt_var...
        rewrite subst_tt_open_tt_var...
        apply H0...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...      
        intros.
        assert ((open_tt (subst_tt X C A1) X0) = subst_tt X C (open_tt A1 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H10.
        rewrite <- subst_tt_open_tt...
        assert ((open_tt (subst_tt X D A2) X0) = subst_tt X D (open_tt A2 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H11.
        rewrite <- subst_tt_open_tt...
        apply H2...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...
        rewrite subst_tt_intro with (X:=X0)...
        remember (subst_tt X0 (open_tt A1 X0) (open_tt A1 X0)).
        rewrite subst_tt_intro with (X:=X0)...
        subst.
        apply posvar_keeps_sign...
      *
        assert (H6:=H3).
        apply soundness in H6.
        apply sub_regular in H6.
        destruct H6.
        destruct H7.
        apply wfs_type in H8.
        apply wfs_type in H7.
        simpl in *.
        apply sa_rec with (L:=L \u L0 \u {{X}} \u dom E  \u fv_tt A2).
        intros.
        rewrite subst_tt_open_tt_var...
        rewrite subst_tt_open_tt_var...
        apply H0...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...
        apply posvar_self_notin...
        apply notin_fv_tt_open_aux...
        intros.
        assert ((open_tt (subst_tt X C A2) X0) = subst_tt X C (open_tt A2 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H10.
        rewrite <- subst_tt_open_tt...
        assert ((open_tt (subst_tt X D A2) X0) = subst_tt X D (open_tt A2 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H11.
        rewrite <- subst_tt_open_tt...
        apply H2...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...      
        apply posvar_self_notin...
        rewrite subst_tt_intro with (X:=X0)...
        apply subst_tt_type...
        apply notin_fv_tt_open_aux...
        apply notin_fv_tt_open_aux...
  -
    intros.
    generalize dependent X.
    generalize dependent C.
    generalize dependent D.
    induction H;intros.
    +
      simpl...
    +
      simpl.
      dependent destruction H2.
      destruct (X==X0).
      destruct H2...
      apply completeness.
      apply refl...      
    +
      simpl.
      constructor...
      apply completeness_wf.
      apply subst_tt_wfs...
      apply soundness in H1.
      apply sub_regular in H1.
      destruct H1.
      destruct H3...
      apply soundness_wf...
    +
      dependent destruction H2.
      simpl in *.
      constructor.
      apply sub_single_implies_double1;try assumption.
      apply posvar_comm...
      apply IHsub2;try assumption.
    +
      dependent destruction H4.
      *
        assert (H6:=H3).
        apply soundness in H6.
        apply sub_regular in H6.
        destruct H6.
        destruct H7.
        apply wfs_type in H8.
        apply wfs_type in H7.
        simpl in *.
        apply sa_rec with (L:=L \u L0 \u {{X}} \u dom E \u fv_tt A1 \u fv_tt A2).
        intros.
        rewrite subst_tt_open_tt_var...
        rewrite subst_tt_open_tt_var...
        apply H0...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...      
        intros.
        assert ((open_tt (subst_tt X D A1) X0) = subst_tt X D (open_tt A1 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H10.
        rewrite <- subst_tt_open_tt...
        assert ((open_tt (subst_tt X C A2) X0) = subst_tt X C (open_tt A2 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H11.
        rewrite <- subst_tt_open_tt...
        apply H2...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...
        rewrite subst_tt_intro with (X:=X0)...
        remember (subst_tt X0 (open_tt A2 X0) (open_tt A2 X0)).
        rewrite subst_tt_intro with (X:=X0)...
        subst.
        apply posvar_keeps_sign...
      *
        assert (H6:=H3).
        apply soundness in H6.
        apply sub_regular in H6.
        destruct H6.
        destruct H7.
        apply wfs_type in H8.
        apply wfs_type in H7.
        simpl in *.
        apply sa_rec with (L:=L \u L0 \u {{X}} \u dom E).
        intros.
        rewrite subst_tt_open_tt_var...
        rewrite subst_tt_open_tt_var...
        apply H0...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...
        apply posvar_self_notin...
        apply notin_fv_tt_open_aux...
        intros.
        assert ((open_tt (subst_tt X D A1) X0) = subst_tt X D (open_tt A1 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H10.
        rewrite <- subst_tt_open_tt...
        assert ((open_tt (subst_tt X C A1) X0) = subst_tt X C (open_tt A1 X0)).      
        rewrite subst_tt_open_tt_var...
        rewrite H11.
        rewrite <- subst_tt_open_tt...
        apply H2...
        rewrite_alist (nil ++ (X0 ~ bind_sub) ++ E).
        apply completeness.
        apply Sub_weakening...
        apply soundness...
        simpl.
        constructor...      
        apply posvar_self_notin...
        assert (X0 \notin L) by auto.
        specialize (H1 _ H12).
        apply soundness in H1.
        apply sub_regular in H1.
        destruct H1.
        destruct H13.
        apply wfs_type in H13...
        apply notin_fv_tt_open_aux...
        apply notin_fv_tt_open_aux...
Qed.

(** Lemma 26 *)
Lemma sub_single_implies_double: forall E A B C D X,
      sub E A B ->
      posvar Pos X A B ->
      sub E C D ->
      sub E (subst_tt X C A) (subst_tt X D B).
Proof with auto.
  intros.
  apply sub_single_implies_double1 with (C:=C) (D:=D) (X:=X) in H...
Qed.
  
(** Lemma 27 *)
Lemma sub_amber_2_to_sub: forall E A B,
    sub_amber2 E A B ->
    sub E A B.
Proof with auto.
  intros.
  induction H...
  -
    apply sa_rec with (L:=L \u fv_tt A \u fv_tt B \u dom E).
    intros...
    intros.
    assert (X \notin L) by auto.
    apply H1 in H3.
    dependent destruction H3.
    pick fresh Y.
    rewrite <- open_subst_twice with (X:=Y)...
    remember (subst_tt Y X (open_tt A (open_tt A Y))).
    rewrite <- open_subst_twice with (X:=Y)...
    subst.
    rewrite_alist (nil ++ (X~bind_sub) ++ E).
    apply sub_replacing...
    simpl.
    rewrite subst_tt_intro with (X:=Y)...
    remember (subst_tt Y (open_tt A Y) (open_tt A Y)).
    rewrite subst_tt_intro with (X:=Y)...
    subst.
    apply sub_single_implies_double...
    apply H0...
    apply H0...
    simpl.
    constructor...
    assert (Y \notin L) by auto.
    apply H0 in H5.
    apply soundness in H5.
    apply sub_regular in H5.
    destruct H5.
    dependent destruction H5...
    apply completeness.
    assert (X \notin L) by auto.
    apply H0 in H5.
    apply soundness in H5.
    apply sub_regular in H5.
    destruct H5.
    destruct H6.
    apply refl...
    rewrite subst_tt_intro with (X:=X)...
    apply subst_tt_wfs...
  -
    apply completeness.
    apply refl...
    apply soundness_wf...
Qed.

(** Theorem 28 (Soundness of the Amber rules) *)
Theorem amber_soundness: forall E A B,
    sub_amber E A B ->
    sub (env_trans E) (rename_env E A) (rename_env E B).
Proof with auto.
  intros.
  apply sub_amber_2_to_sub.
  apply sub_amber_to_amber_2...
Qed.

Theorem amber_soundness2: forall E A B,
    sub_amber E A B ->
    Sub (env_trans E) (rename_env E A) (rename_env E B).
Proof with auto.
  intros.
  apply soundness...
  apply amber_soundness...
Qed.
