#lang racket
(require minikanren)

(define (no-repeats lst)
  (local [(define objects 5)
          (define attributes 6)

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
  (fresh (d1 d2 d3 d4 d5)
         (== `(Boys ,d1 ,d2 ,d3 ,d4 ,d5) solution)
         (conde
          ((== d1 donor-a) (== d2 donor-b))
          ((== d2 donor-a) (== d3 donor-b))
          ((== d3 donor-a) (== d4 donor-b))
          ((== d4 donor-a) (== d5 donor-b)))))

(defrel (next-to donor-a donor-b solution)
  (conde
   ((to-the-left/right-of donor-a donor-b solution))
   ((to-the-left/right-of donor-b donor-a solution))))

(defrel (at-one-of-the-ends donor solution)
  (fresh (d1 d2 d3 d4 d5)
         (== `(Boys ,d1 ,d2 ,d3 ,d4 ,d5) solution)
         (conde
          ((== d1 donor))
          ((== d5 donor)))))

(defrel (somewhere-to-the-left/right-of donor-a donor-b solution)
  (fresh (d1 d2 d3 d4 d5)
         (== `(Boys ,d1 ,d2 ,d3 ,d4 ,d5) solution)
         (conde
          ((== d1 donor-a) (conde ((== d2 donor-b))
                                  ((== d3 donor-b))
                                  ((== d4 donor-b))
                                  ((== d5 donor-b))))
          ((== d2 donor-a) (conde ((== d3 donor-b))
                                  ((== d4 donor-b))
                                  ((== d5 donor-b))))
          ((== d3 donor-a) (conde ((== d4 donor-b))
                                  ((== d5 donor-b))))
          ((== d4 donor-a) (== d5 donor-b)))))

(defrel (somewhere-between donor-a donor-b donor-c solution)
  (fresh (d1 d2 d3 d4 d5)
         (== `(Boys ,d1 ,d2 ,d3 ,d4 ,d5) solution)
         (conde
          ((== d1 donor-a) (== d5 donor-c) (conde ((== d2 donor-b))
                                                  ((== d3 donor-b))
                                                  ((== d4 donor-b))))
          ((== d1 donor-a) (== d4 donor-c) (conde ((== d2 donor-b))
                                                  ((== d3 donor-b))))
          ((== d1 donor-a) (== d3 donor-c) (== d2 donor-b))
          ((== d2 donor-a) (== d5 donor-c) (conde ((== d3 donor-b))
                                                  ((== d4 donor-b))))
          ((== d3 donor-a) (== d5 donor-c) (== d4 donor-b))
          ((== d2 donor-a) (== d4 donor-c) (== d3 donor-b)))))

(defrel (at-position x p solution)
  (fresh (b1 b2 b3 b4 b5)
         (== `(Boys ,b1 ,b2 ,b3 ,b4 ,b5) solution)
         (conde
          ((== p 1) (== x b1))
          ((== p 2) (== x b2))
          ((== p 3) (== x b3))
          ((== p 4) (== x b4))
          ((== p 5) (== x b5)))))

(defrel (kathleen-is-forty solution)
  (fresh (shirt blood weight job)
         (membero `(,shirt Kathleen ,blood 40 ,weight ,job) solution)))

(defrel (b+-donor-weight-140 solution)
  (fresh (shirt name age job)
         (membero `(,shirt ,name B+ ,age 140 ,job) solution)))

(defrel (universal-donor-is-35 solution)
  (fresh (shirt name weight job)
         (membero `(,shirt ,name O- 35 ,weight ,job) solution)))

(defrel (A+-next-to-B+ solution)
  (fresh (shirt1 name1 age1 weight1 job1
                 shirt2 name2 age2 weight2 job2)
         (next-to `(,shirt1 ,name1 A+ ,age1 ,weight1 ,job1)
                  `(,shirt2 ,name2 B+ ,age2 ,weight2, job2)
                  solution)))

(defrel (brooke-at-end solution)
  (fresh (shirt blood age weight job)
         (at-one-of-the-ends `(,shirt Brooke ,blood ,age ,weight ,job) solution)))

(defrel (actress-next-to-chef solution)
  (fresh (shirt1 name1 blood1 age1 weight1
                 shirt2 name2 blood2 age2 weight2)
         (next-to `(,shirt1 ,name1 ,blood1 ,age1 ,weight1 Chef)
                  `(,shirt2 ,name2 ,blood2 ,age2 ,weight2 Actress)
                  solution)))

(defrel (brooke-next-to-nicole solution)
  (fresh (shirt1 blood1 age1 weight1 job1
                 shirt2 blood2 age2 weight2 job2)
         (next-to `(,shirt1 Brooke ,blood1 ,age1 ,weight1 ,job1)
                  `(,shirt2 Nicole ,blood2 ,age2 ,weight2 ,job2)
                  solution)))

(defrel (35-left-of-30 solution)
  (fresh (shirt1 name1 blood1 weight1 job1
                 shirt2 name2 blood2 weight2 job2)
         (to-the-left/right-of
          `(,shirt1 ,name1 ,blood1 35 ,weight1 ,job1)
          `(,shirt2 ,name2 ,blood2 30 ,weight2 ,job2)
          solution)))

(defrel (kathleen-at-one-of-the-ends solution)
  (fresh (shirt blood age weight job)
         (at-one-of-the-ends
          `(,shirt Kathleen ,blood ,age ,weight ,job)
          solution)))

(defrel (AB+-left-of-A+ solution)
  (fresh (shirt1 name1 age1 weight1 job1
                 shirt2 name2 age2 weight2 job2)
         (to-the-left/right-of
          `(,shirt1 ,name1 AB+ ,age1 ,weight1 ,job1)
          `(,shirt2 ,name2 A+ ,age2 ,weight2 ,job2)
          solution)))

(defrel (130-at-end solution)
  (fresh (shirt name blood age job)
  (at-one-of-the-ends
   `(,shirt ,name ,blood ,age 130 ,job)
   solution)))

(defrel (black-shirt-somewhere-left-150 solution)
  (fresh (name1 blood1 age1 weight1 job1
                shirt2 name2 blood2 age2 job2)
         (somewhere-to-the-left/right-of
          `(Black ,name1 ,blood1 ,age1 ,weight1 ,job1)
          `(,shirt2 ,name2 ,blood2 ,age2 150 ,job2)
          solution)))

(defrel (florist-somewhere-right-of-purple solution)
  (fresh (shirt1 name1 blood1 age1 weight1
                 name2 blood2 age2 weight2 job2)
         (somewhere-to-the-left/right-of
          `(Purple ,name2 ,blood2 ,age2, weight2 ,job2)
          `(,shirt1 ,name1 ,blood1 ,age1 ,weight1 Florist)
          solution)))

(defrel (purple-somewhere-right-of-green solution)
  (fresh (name1 blood1 age1 weight1 job1
          name2 blood2 age2 weight2 job2)
         (somewhere-to-the-left/right-of
          `(Green ,name1 ,blood1 ,age1 ,weight1 ,job1)
          `(Purple ,name2 ,blood2 ,age2 ,weight2 ,job2)
          solution)))

(defrel (meghan-somewhere-right-of-purple solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2)
         (somewhere-to-the-left/right-of
          `(Purple ,name1 ,blood1 ,age1 ,weight1 ,job1)
          `(,shirt2 Meghan ,blood2 ,age2 ,weight2 ,job2)
          solution)))

(defrel (blue-somewhere-left-red solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2)
         (somewhere-to-the-left/right-of
          `(Blue ,name1 ,blood1 ,age1 ,weight1 ,job1)
          `(Red ,name2 ,blood2 ,age2 ,weight2 ,job2)
          solution)))

(defrel (oldest-weighs-130 solution)
  (fresh (shirt name blood age weight job)
         (membero
          `(,shirt ,name ,blood 45 130 ,job)
          solution)))

(defrel (youngest-next-to-30 solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2)
         (next-to
          `(,shirt1 ,name1 ,blood1 25 ,weight1 ,job1)
          `(,shirt2 ,name2 ,blood2 30 ,weight2 ,job2)
          solution)))

(defrel (AB+-next-to-youngest solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2)
         (next-to
          `(,shirt1 ,name1 AB+ ,age1 ,weight1 ,job1)
          `(,shirt2 ,name2 ,blood2 25 ,weight2 ,job2)
          solution)))

(defrel (120-between-O--and-150 solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2
          shirt3 name3 blood3 age3 weight3 job3)
         (somewhere-between
          `(,shirt1 ,name1 O- ,age1 ,weight1 ,job1)
          `(,shirt2 ,name2 ,blood2 ,age2 120 ,job2)
          `(,shirt3 ,name3 ,blood3 ,age3 150 ,job3)
          solution)))

(defrel (green-between-actress-and-red solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2
          shirt3 name3 blood3 age3 weight3 job3)
         (somewhere-between
          `(,shirt1 ,name1 ,blood1 ,age1 ,weight1 Actress)
          `(Green ,name2 ,blood2 ,age2, weight2 ,job2)
          `(Red ,name3 ,blood3 ,age3, weight3 ,job3)
          solution)))

(defrel (florist-between-actress-engineer solution)
  (fresh (shirt1 name1 blood1 age1 weight1 job1
          shirt2 name2 blood2 age2 weight2 job2
          shirt3 name3 blood3 age3 weight3 job3)
         (somewhere-between
          `(,shirt1 ,name1 ,blood1 ,age1 ,weight1 Actress)
          `(,shirt2 ,name2 ,blood2 ,age2 ,weight2 Florist)
          `(,shirt3 ,name3 ,blood3 ,age3 ,weight3 Engineer)
          solution)))



(defrel (zebra-puzzle solution)
  (fresh (d1 d2 d3 d4 d5)
  (== `(Boys ,d1 ,d2 ,d3 ,d4 ,d5) solution))
  (kathleen-is-forty solution)
  (b+-donor-weight-140 solution)
  (universal-donor-is-35 solution)
  (A+-next-to-B+ solution)
  (brooke-at-end solution)
  (actress-next-to-chef solution)
  (brooke-next-to-nicole solution)
  (35-left-of-30 solution)
  (kathleen-at-one-of-the-ends solution)
  (AB+-left-of-A+ solution)
  (130-at-end solution)
  (black-shirt-somewhere-left-150 solution)
  (florist-somewhere-right-of-purple solution)
  (purple-somewhere-right-of-green solution)
  (meghan-somewhere-right-of-purple solution)
  (blue-somewhere-left-red solution)
  (oldest-weighs-130 solution)
  (youngest-next-to-30 solution)
  (AB+-next-to-youngest solution)
  (120-between-O--and-150 solution)
  (green-between-actress-and-red solution)
  (florist-between-actress-engineer solution))



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

(filter no-repeats (run* (q) (zebra-puzzle q)))