Require Import Category.Core Functor.Core.
Require Import Category.Dual Functor.Dual.
Require Import Functor.Composition.Core Functor.Identity.
Require Import Cat.Core Functor.Paths.
Require Import types.Sigma HProp HoTT.Tactics types.Forall.

Set Universe Polymorphism.
Set Implicit Arguments.
Generalizable All Variables.
Set Asymmetric Patterns.

Local Open Scope category_scope.

Section opposite.
  Context `{Funext}.

  Variable P : PreCategory -> Type.
  Context `{forall C, IsHProp (P C)}.
  Context `{HF : forall C D, P C -> P D -> IsHSet (Functor C D)}.

  Local Notation cat := (@sub_pre_cat _ P HF).

  Hypothesis has_op : forall C : cat, P C.1^op.

  Definition opposite_functor : Functor cat cat
    := Build_Functor
         cat cat
         (fun C => (C.1^op; has_op _))
         (fun _ _ F => F^op)%functor
         (fun _ _ _ _ _ => idpath)
         (fun _ => idpath).

  Let opposite_functor_involutive_helper (x : cat)
  : (x.1^op^op; has_op (_; has_op _)) = x
    := path_sigma_uncurried
         P
         (((x.1^op)^op)%category;
          has_op ((x.1^op)%category;
                  has_op x))
         x
         (Category.Dual.opposite_involutive x.1;
          allpath_hprop _ _).

  Local Open Scope functor_scope.

  Local Opaque path_sigma_uncurried.

  Definition opposite_functor_involutive
  : opposite_functor o opposite_functor = 1.
  Proof.
    path_functor.
    refine (path_forall _ _ opposite_functor_involutive_helper; _).
    repeat (apply path_forall; intro).
    rewrite !transport_forall_constant.
    transport_path_forall_hammer.
    unfold opposite_functor_involutive_helper.
    rewrite !transport_projT1_path_sigma_uncurried.
    simpl in *.
    repeat progress change (fun x => ?f x) with f in *.
    match goal with
      | [ |- appcontext[transport
                          (fun x' => ?f x'.1 ?y)
                          (@path_sigma_uncurried ?A ?P ?u ?v ?pq)] ]
        => rewrite (@transport_projT1_path_sigma_uncurried
                      A P u v pq
                      (fun x => f x y))
    end.
    simpl in *.
    destruct_head_hnf @sigT.
    destruct_head_hnf @Functor.
    destruct_head_hnf @PreCategory.
    reflexivity.
  Qed.
End opposite.
