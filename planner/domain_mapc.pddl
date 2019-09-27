(define (domain mapc)
   (:requirements :strips :typing :equality :action-costs :negative-preconditions)
   
   (:types
        agent block obstacle - entity
        cell
        direction
        rotation_direction
    )

    (:constants
        a - agent
        p0n5
        n1n4 p0n4 p1n4
        n2n3 n1n3 p0n3 p1n3 p2n3
        n3n2 n2n2 n1n2 p0n2 p1n2 p2n2 p3n2
        n4n1 n3n1 n2n1 n1n1 p0n1 p1n1 p2n1 p3n1 p4n1
        n5p0 n4p0 n3p0 n2p0 n1p0 p0p0 p1p0 p2p0 p3p0 p4p0 p5p0
        n4p1 n3p1 n2p1 n1p1 p0p1 p1p1 p2p1 p3p1 p4p1
        n3p2 n2p2 n1p2 p0p2 p1p2 p2p2 p3p2
        n2p3 n1p3 p0p3 p1p3 p2p3
        n1p4 p0p4 p1p4
        p0p5 - cell
        n e s w - direction
        cw ccw - rotation_direction
    )

   (:predicates 
        (at ?x - entity ?c - cell)
        (attached ?a - agent ?b - block)
        (adjacent ?d  - direction ?c1 ?c2 - cell )
        (rotation ?r - rotation_direction ?d1 ?d2 - direction)
        (alone ?a - agent)   ;; <-> forall (?b - block) (not (attached ?a ?b))
        (empty ?c - cell)    ;; <-> forall (?e - entity) (not (at ?e ?c))
    )
    
    (:functions
;;        (clears)      ;; number of possible clear actions
        (total-cost)  ;; number of steps
    )
    
   (:action move
        :parameters (?d - direction ?c1 ?c2 - cell)
        :precondition (
            and (at a ?c1) (adjacent ?d ?c1 ?c2) (empty ?c2) (alone a)
        )
        :effect (
            and (not (at a ?c1)) (at a ?c2) (empty ?c1) (not (empty ?c2)) (increase (total-cost) 1)
        )
    )
    
    (:action move_w_block_1 ;; moving in direction of the attached block
        :parameters (?d - direction ?c0 ?c1 ?c2 - cell ?b - block)
        :precondition(
            and
                (at a ?c0) (at ?b ?c1) (adjacent ?d ?c0 ?c1) (attached a ?b)
                (adjacent ?d ?c1 ?c2) (empty ?c2)
        )
        :effect(
            and
                (not (at a ?c0)) (not (at ?b ?c1)) (at a ?c1) (at ?b ?c2) 
                (empty ?c0) (not (empty ?c2)) (increase (total-cost) 1)
        )
    )
    
    (:action move_w_block_2 ;; moving in opposite direction of the attached block
        :parameters (?d - direction ?c0 ?c1 ?c2 - cell ?b - block)
        :precondition(
            and
                (at a ?c0) (at ?b ?c1) (adjacent ?d ?c1 ?c0) (attached a ?b)
                (adjacent ?d ?c0 ?c2) (empty ?c2)
        )
        :effect(
            and
                (not (at a ?c0)) (not (at ?b ?c1)) (at a ?c2) (at ?b ?c0)
                (empty ?c1) (not (empty ?c2)) (increase (total-cost) 1)
        )
    )
    
    (:action move_w_block_3 ;; moving orthogonally to the block
        :parameters (?d1 ?d2 - direction ?c0 ?c1 ?c2 ?c3 - cell ?b - block) ;; d1 direction where we want to move, d2 direction of the attached block
                                                                            ;; c0 agent cell, c1 block cell, c2 agent destination, c3 block destination
        :precondition(
            and
                (at a ?c0) (at ?b ?c1) (adjacent ?d2 ?c0 ?c1) (attached a ?b)
                (adjacent ?d1 ?c0 ?c2) (adjacent ?d1 ?c1 ?c3) (empty ?c2) (empty ?c3)
        )
        :effect(
            and
                (not (at a ?c0)) (not (at ?b ?c1)) (at a ?c2) (at ?b ?c3)
                (empty ?c0) (empty ?c1) (not (empty ?c2)) (not (empty ?c3))
                (increase (total-cost) 1)
        )
    )
    
    (:action clear_1 ;; all cells with obstacles
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?o0 ?o1 ?o2 ?o3 ?o4 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (adjacent n ?c0 ?c1) (adjacent e ?c0 ?c2) (adjacent s ?c0 ?c3) (adjacent w ?c0 ?c4)
                (at ?o0 ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (at ?o3 ?c3) (at ?o4 ?c4)
        )
        :effect (
            and
                (not (at ?o0 ?c0)) (not (at ?o1 ?c1)) (not (at ?o2 ?c2)) 
                (not (at ?o3 ?c3)) (not (at ?o4 ?c4)) (empty ?c0) (empty ?c1)
                (empty ?c2) (empty ?c3) (empty ?c4)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_2 ;; 4 cells with obstacles including the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o0 ?o1 ?o2 ?o3 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (at ?o0 ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (at ?o3 ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o0 ?c0)) (not (at ?o1 ?c1)) (not (at ?o2 ?c2)) (not (at ?o3 ?c3))
                (empty ?c0) (empty ?c1) (empty ?c2) (empty ?c3)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_3 ;; 4 cells with obstacles, but not the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?o1 ?o2 ?o3 ?o4 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (adjacent n ?c0 ?c1) (adjacent e ?c0 ?c2) (adjacent s ?c0 ?c3) (adjacent w ?c0 ?c4)
                (empty ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (at ?o3 ?c3) (at ?o4 ?c4)
        )
        :effect (
            and
                (not (at ?o1 ?c1)) (not (at ?o2 ?c2)) (not (at ?o3 ?c3)) (not (at ?o4 ?c4))
                (empty ?c1) (empty ?c2) (empty ?c3) (empty ?c4)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_4 ;; 3 cells with obstacles including the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o0 ?o1 ?o2 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (at ?o0 ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (empty ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o0 ?c0)) (not (at ?o1 ?c1)) (not (at ?o2 ?c2))
                (empty ?c0) (empty ?c1) (empty ?c2)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_5 ;; 3 cells with obstacles, but not the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o1 ?o2 ?o3 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (empty ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (at ?o3 ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o1 ?c1)) (not (at ?o2 ?c2)) (not (at ?o3 ?c3))
                (empty ?c1) (empty ?c2) (empty ?c3)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_6 ;; 2 cells with obstacles including the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o0 ?o1 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (at ?o0 ?c0) (at ?o1 ?c1) (empty ?c2) (empty ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o0 ?c0)) (not (at ?o1 ?c1)) (empty ?c0) (empty ?c1)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_7 ;; 2 cells with obstacles, but not the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o1 ?o2 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (empty ?c0) (at ?o1 ?c1) (at ?o2 ?c2) (empty ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o1 ?c1)) (not (at ?o2 ?c2)) (empty ?c1) (empty ?c2)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_8 ;; 1 cell with obstacle, but not the center
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?d0 ?d1 ?d2 ?d3 - direction
            ?o1 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (not (= ?d0 ?d1)) (not (= ?d0 ?d2)) (not (= ?d0 ?d3))
                (not (= ?d1 ?d2)) (not (= ?d1 ?d3)) (not (= ?d2 ?d3))
                (adjacent ?d0 ?c0 ?c1) (adjacent ?d1 ?c0 ?c2) (adjacent ?d2 ?c0 ?c3) (adjacent ?d3 ?c0 ?c4)
                (empty ?c0) (at ?o1 ?c1) (empty ?c2) (empty ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o1 ?c1)) (empty ?c1)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action clear_9 ;; only the center contains an obstacle
        :parameters (
            ?c0 ?c1 ?c2 ?c3 ?c4 - cell
            ?o0 - obstacle
        )
        :precondition (
            and
                ;;(> (clears) 0)
		(at a p0p0)
                (adjacent n ?c0 ?c1) (adjacent e ?c0 ?c2) (adjacent s ?c0 ?c3) (adjacent w ?c0 ?c4)
                (at ?o0 ?c0) (empty ?c1) (empty ?c2) (empty ?c3) (empty ?c4)
        )
        :effect (
            and
                (not (at ?o0 ?c0)) (empty ?c0)
                (increase (total-cost) 3) ;;(decrease (clears) 1)
        )
    )
    
    (:action rotate
        :parameters (?r - rotation_direction ?d1 ?d2 - direction ?b - block ?c0 ?c1 ?c2 - cell)
        :precondition (
            and
                (rotation ?r ?d1 ?d2) (at ?b ?c1) (at a ?c0) (attached a ?b)
                (adjacent ?d1 ?c0 ?c1) (adjacent ?d2 ?c0 ?c2) (empty ?c2)
        )
        :effect (
            and (not (at ?b ?c1)) (at ?b ?c2) (empty ?c1) (not (empty ?c2))
            (increase (total-cost) 1)
        )
    )
    
;;    (:action attach
;;        :parameters (?d - direction ?c0 ?c1 - cell ?b - block)
;;        :precondition(
;;            and
;;                (at a ?c0) (alone a) (at ?b ?c1) (adjacent ?d ?c0 ?c1)
;;        )
;;        :effect(
;;            and (attached a ?b) (not (alone a)) (increase (total-cost) 1)
;;        )
;;    )
    
;;    (:action detach
;;        :parameters (?d - direction ?c0 ?c1 - cell ?b - block)
;;        :precondition(
;;            and
;;                (at a ?c0) (attached a ?b) (at ?b ?c1) (adjacent ?d ?c0 ?c1)
;;        )
;;        :effect(
;;            and (not (attached a ?b)) (alone a) (increase (total-cost) 1)
;;        )
;;   )
)