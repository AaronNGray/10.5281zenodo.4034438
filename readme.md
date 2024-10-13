Revisiting Iso-Recursive Subtyping (Artifact)
-----

## Abstract
This bundle contains the Coq formulation associated with the paper "Revisiting Iso-Recursive Subtyping". This document explains how to run the Coq formulations. 

## Getting Started

- If your computer has installed ```opam2```, we strongly recommend you to install Coq proof assistant by yourself.

	1. Install [Coq](https://coq.inria.fr/opam-using.html)(>=8.10). The latest version of Coq is 8.12. In Ubuntu-like system, you can install Coq by typing these commands in terminal.
	
		```shell
		>> opam install opam-depext
		>> opam-depext coq
		>> sudo apt-get install m4
		>> opam pin add coq 8.12.0
		```

	2. Install [metalib](https://github.com/plclub/metalib). In terminal, type

		```
		>> git clone https://github.com/plclub/metalib.git
		>> cd metalib/Metalib
		>> make
		>> make install
		```
	3. Now to compile our Coq proof where a ```makefile``` is provided. In command line, cd to the ```src``` directory and then build the whole project.
	
		```
		>> cd path_to_src
		>> make clean
		>> make
		>> make html
		```
- If you do not have OCaml, we also provide a [VirtualBox](https://www.virtualbox.org/) image. Import the .ova file and all the coq files were compiled. 

	1. Download VirtualBox.
	2. Download .ova file from [google drive](https://drive.google.com/file/d/1zCUzpY_gw3XfE23DR6pKyyUHSyZSsERT/view?usp=sharing)(3GB large).
	3. Start VirtualBox and import ```paper512.ova```. Username: ```user``` Password: ```123456```.
	4. The compiled codes are located in home folder.

## Coq files

| Coq File | Description |
|  ----  | ----  |
| definition.v | The definition of the SLTC extended with our recursive subtyping formulation, including Well-Formedness, Subtyping (declarative and algorithmic), Typing, Reduction, Subderivation and Negative Subtyping. |
| infra.v | Infrastructure about locally nameless. |
| subtyping.v | Theorems about subtyping. |
| typesafety.v | Theorems about type soundness. |
| decidability.v| Theorem showing that our recursive subtyping is decidable. |
| amber\_part_1.v |  Definitions of Amber rules and positive restriction. Theorem showing that amber rules is sound w.r.t to the positive restriction. |
| amber\_part_2.v | Theorem showing that amber rules is sound w.r.t to our subtyping formulation. |

## Definitions
| Definition |  File | Name of formalization | Notation |
|  ----  | ----  | ---- | ---- |
| n-times finite unfolding (Definition 1)* | definition.v | def1 | |
| Well-formed Type (Figure 3) | definition.v | WF E A | $\Gamma \vdash A $ |
| Well-formed Type (Definition 2)** | definition.v | WFS E A | $\Gamma \vdash A $ |
| Declarative subtyping (Figure 3) | definition.v | Sub E A B | $\Gamma \vdash A \le B $ |
| Typing (Figure 4) | definition.v | typing E e A | $ \Gamma \vdash e : A $ |
| Reduction (Figure 4) | definition.v | step e1 e2  | $ e_1 \hookrightarrow e_2 $ |
| Algorithmic subtyping (Figure 5) | definition.v | sub E A B | $\Gamma \vdash_{a} A \le B $ |
| Subtyping Subderivation (Figure 6) | definition.v | Der m E2 A B E1 C D | $\Gamma_1, \Gamma_2 \vdash A \le B \in_{m} C \le D $ |
| Negative Subtyping (Figure 6) | definition.v | NTyp E m X A B | $\Gamma \vdash_{m}^{\alpha} A \le B $ |
| Well-formed Type of Amber rules (Figure 7) | amber\_part\_1.v | wf_amber E A | $\Delta \vdash A $ |
| Amber rules (Figure 7) | amber\_part\_1.v | sub_amber E A B | $\Delta \vdash_{amb} A \le B $ |
| Positive restriction (Figure 8) | amber\_part\_1.v | posvar m X A B | $\alpha \in_{m} A \le_{+} B $ |
| Positive subtyping (Figure 8) | amber\_part\_1.v | sub\_amber2 E A B | $\Gamma \vdash A \le_{+} B $ |
| Translation of environments and types from the Amber rules (Definition 24) | amber\_part\_1.v | env\_trans & rename\_env | |


* *Because we use locally nameless as presentation, the coq code frequently uses ```open``` operator instead of ```substitute``` operator. In lemma ```def1_eq_open_tt``` (in file ```infra.v```), we prove these two presentations are equivalent.
* **This definition of well-formed contains rule ```WFT-INF``` instead of ```WFT-REC```. We prove that ```WFS``` is sound and complete w.r.t ```WF``` by lemmas ```soundness_wf``` and ```completeness_wf``` in file ```subtyping.v```.


## Lemmas and Theorems

| Lemma/Theorem |  File | Lemma Name in Coq File |
|  ----  | ----  | ---- |
| Lemma 3 | subtyping.v | sub_regular |
| Theorem 4 (Reflexivity)| subtyping.v | refl |
| Theorem 5 (Transitivity) | subtyping.v | Transitivity |
| Theorem 6 (Decidability) | decidability.v | decidability |
| Lemma 7 *** | subtyping.v | subst\_rec\_col |
| Lemma 8 (Unfolding Lemma) | subtyping.v | unfolding_lemma |
| Lemma 9 | typesafety.v | typing\_through\_subst\_ee |
| Theorem 10 (Preservation) | typesafety.v | preservation |
| Theorem 11 (Progress) | typesafety.v | progress |
| Lemma 12 | subtyping.v | suba_regular |
| Theorem 13 (Reflexivity)| subtyping.v | refl_algo |
| Theorem 14 (Transitivity) | subtyping.v | trans_algo |
| Theorem 15 (Completeness of algorithmic subtyping) | subtyping.v | completeness |
| Lemma 16 | subtyping.v | der\_sub\_whole & der\_sub\_sub |
| Lemma 17 *** | subtyping.v | gnegative\_lemma |
| Lemma 18 | infra.v | Sub\_eq | 
| Lemma 19 *** | subtyping.v | negative\_lemma |
| Lemma 20 *** | subtyping.v | sub\_generalize\_intensive |
| Lemma 21 | subtyping.v | sub\_subst |
| Theorem 22 (Soundness of algorithmic subtyping) | subtyping.v | soundness |
| Lemma 23 | amber\_part\_2.v | posvar\_keeps\_sign |
| Lemma 25 | amber\_part\_1.v | sub\_amber\_to\_amber\_2 |
| Lemma 26 | amber\_part\_2.v | sub\_single\_implies\_double |
| Lemma 27 | amber\_part\_2.v | sub\_amber\_2\_to\_sub |
| Theorem 28 (Soundness of the Amber rules) | amber\_part\_2.v | amber\_soundness |

* *** Lemma 7, 17, 19 and 20 have syntax sugar ```unfoldT```, ```chooseS``` and ```chooseD```(Definition can be found at file ```definition.v```). In the paper, we show the formulation after desugaring.

## Dependency

	definition - infra - subtyping --- typesafety
                            | 
                            | ------- decidability
                            |
                             -------- amber_part_1 ----- amber_part_2