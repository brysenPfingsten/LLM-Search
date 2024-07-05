#lang racket

(require minikanren)

(define (no-repeats lst)
  (local [(define objects 4)
          (define attributes 5)

          (define solution
            (foldl (λ (i accum) (append i accum))
                   '()
                   (rest lst)))]
    (= (* objects attributes)
       (set-count (list->set solution)))))
       
  

(define (membero x lst)
  (conde
   [(== lst '()) (== 'f 't)]
   [(fresh (a ad)
           (== `(,a . ,ad) lst)
           (conde
            [(== x a)]
            [(membero x ad)]))]))

(defrel (to-the-left/right-of donor-a donor-b solution)
  (fresh (d1 d2 d3 d4)
         (== `(Boys ,d1 ,d2 ,d3 ,d4) solution)
         (conde
          ((== d1 donor-a) (== d2 donor-b))
          ((== d2 donor-a) (== d3 donor-b))
          ((== d3 donor-a) (== d4 donor-b)))))

(defrel (next-to donor-a donor-b solution)
  (conde
   ((to-the-left/right-of donor-a donor-b solution))
   ((to-the-left/right-of donor-b donor-a solution))))

(defrel (at-one-of-the-ends donor solution)
  (fresh (d1 d2 d3 d4)
         (== `(Boys ,d1 ,d2 ,d3 ,d4) solution)
         (conde
          ((== d1 donor))
          ((== d4 donor)))))

(defrel (somewhere-to-the-left/right-of donor-a donor-b solution)
  (fresh (d1 d2 d3 d4)
         (== `(Boys ,d1 ,d2 ,d3 ,d4) solution)
         (conde
          ((== d1 donor-a) (conde ((== d2 donor-b))
                                  ((== d3 donor-b))
                                  ((== d4 donor-b))))
          ((== d2 donor-a) (conde ((== d3 donor-b))
                                  ((== d4 donor-b))))
          ((== d3 donor-a) (== d4 donor-b)))))

(defrel (somewhere-between donor-a donor-b donor-c solution)
  (fresh (d1 d2 d3 d4)
         (== `(Boys ,d1 ,d2 ,d3 ,d4) solution)
         (conde
          ((== d1 donor-a) (== d4 donor-c) (conde ((== d2 donor-b))
                                                  ((== d3 donor-b))))
          ((== d1 donor-a) (== d3 donor-c) (== d2 donor-b))
          ((== d2 donor-a) (== d4 donor-c) (== d3 donor-b)))))

(defrel (at-position x p solution)
  (fresh (b1 b2 b3 b4 b5)
         (== `(Boys ,b1 ,b2 ,b3 ,b4) solution)
         (conde
          ((== p 1) (== x b1))
          ((== p 2) (== x b2))
          ((== p 3) (== x b3))
          ((== p 4) (== x b4)))))




(defrel (joshua-at-end solution)
  (fresh (shirt name movie snack age)
  (at-one-of-the-ends
   `(,shirt Joshua ,movie ,snack ,age)
   solution)))

(defrel (black-left-of-youngest solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2)
         (to-the-left/right-of
          `(Black ,name1 ,movie1 ,snack1 ,age1)
          `(,shirt2 ,name2 ,movie2 ,snack2 11)
          solution)))

(defrel (joshua-likes-horror solution)
  (fresh (shirt name movie snack age)
         (membero
          `(,shirt Joshua Horror ,snack ,age)
          solution)))

(defrel (14y/o-at-third solution)
  (fresh (shirt name movie snack age)
         (at-position
          `(,shirt ,name ,movie ,snack 14)
          3
          solution)))

(defrel (red-between-13-and-action solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2
          shirt3 name3 movie3 snack3 age3)
         (somewhere-between
          `(,shirt1 ,name1 ,movie1 ,snack1 13)
          `(Red ,name2 ,movie2 ,snack2 ,age2)
          `(,shirt3 ,name3 Action ,snack3 ,age3)
          solution)))

(defrel (daniel-likes-thrillers solution)
  (fresh (shirt name movie snack age)
         (membero
          `(,shirt Daniel Thrillers ,snack ,age)
          solution)))

(defrel (cookies-at-ends solution)
  (fresh (shirt name movie snack age)
         (at-one-of-the-ends
          `(,shirt ,name ,movie Cookies ,age)
          solution)))

(defrel (black-left-of-thriller solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2)
         (to-the-left/right-of
          `(Black ,name1 ,movie1 ,snack1 ,age1)
          `(,shirt2 ,name2 Thrillers ,snack2 ,age2)
          solution)))

(defrel (crackers-right-of-comedy solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2)
         (to-the-left/right-of
          `(,shirt1 ,name1 Comedy ,snack1 ,age1)
          `(,shirt2 ,name2 ,movie2 Crackers ,age2)
          solution)))

(defrel (red-between-popcorn-and-nicholas solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2
          shirt3 name3 movie3 snack3 age3)
         (somewhere-between
          `(,shirt1 ,name1 ,movie1 Popcorn ,age1)
          `(Red ,name2 ,movie2 ,snack2 ,age2)
          `(,shirt3 Nicholas ,movie3 ,snack3 ,age3)
          solution)))

(defrel (thriller-at-ends solution)
  (fresh (shirt name movie snack age)
         (at-one-of-the-ends
          `(,shirt ,name Thrillers ,snack ,age)
          solution)))

(defrel (nicholas-between-joshua-and-daniel solution)
  (fresh (shirt1 name1 movie1 snack1 age1
          shirt2 name2 movie2 snack2 age2
          shirt3 name3 movie3 snack3 age3)
         (somewhere-between
          `(,shirt1 Joshua ,movie1 ,snack1 ,age1)
          `(,shirt2 Nicholas ,movie2 ,snack2 ,age2)
          `(,shirt3 Daniel ,movie3 ,snack3 ,age3)
          solution)))

(defrel (green-at-first solution)
  (fresh (shirt name movie snack age)
  (at-position
   `(Green ,name ,movie ,snack ,age)
   1
   solution)))

(defrel (zebra-puzzle2 solution)
  (fresh (b1 b2 b3 b4)
         (== `(Boys ,b1 ,b2 ,b3 ,b4) solution))
  (joshua-at-end solution)
  (black-left-of-youngest solution)
  (joshua-likes-horror solution)
  (14y/o-at-third solution)
  (red-between-13-and-action solution)
  (daniel-likes-thrillers solution)
  (cookies-at-ends solution)
  (black-left-of-thriller solution)
  (crackers-right-of-comedy solution)
  (red-between-popcorn-and-nicholas solution)
  (thriller-at-ends solution)
  (nicholas-between-joshua-and-daniel solution)
  (green-at-first solution)
  )

(filter no-repeats (run* (q) (zebra-puzzle2 q)))