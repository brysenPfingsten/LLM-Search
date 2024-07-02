#lang racket

(require net/http-easy
         json
         minikanren)

(define texts (list "I can work Monday and Wednesday mornings, or Thursday and Friday evenings. Cannot do Tuesday at all."
                    "Available Tuesday to Thursday mornings, or any afternoon except Friday. I need Saturday off."
                    "I can work Monday or Wednesday, but not both. Prefer late shifts on these days."
                    "Happy to work Friday or Sunday, but not both. Available all other days, preferably mornings."
                    "Available Monday through Wednesday afternoons. Either I can take the Thursday morning shift or the Friday evening shift, but not both."
                    "This week, I can work early shifts on Tuesday or Thursday, but if I work Thursday, I cannot work Monday at all."
                    "Available for evening shifts on Monday and Wednesday, or morning shifts on Friday and Saturday. Not available Tuesday."
#|                     "I can work any shift on Wednesday or Thursday, but if I take Thursday, I need Tuesday off completely."
                       "I can work any two consecutive days between Monday and Thursday, but I cannot work both Monday and Thursday."
                       "I’m available for any morning shifts on Tuesday and Thursday, but if I work on Thursday, I need Wednesday off."
                       "Can work either Monday and Wednesday or Thursday and Saturday, but not both pairs. Prefer morning shifts."
                       "Available Tuesday to Friday afternoons. If I work on Tuesday, I cannot work Thursday evening."
                       "Can take Monday and Tuesday shifts or Wednesday and Thursday shifts, but not both. I need Friday and Sunday off."
                       "Available for late shifts on Monday and Wednesday, or any shift on Friday, but not both. Need Tuesday off."
                       "I can work any opening shifts on Monday, Wednesday, and Friday, but if I work Friday, I cannot do Monday."
                       "Happy to work Thursday and Friday, but if I take Thursday, I need Saturday off. Available all other days."
                       "I can work Monday or Wednesday, but if I work Monday, I need to leave by 3 PM. If I work Wednesday, I can stay late."
                       "Available any shifts Tuesday, Thursday, or Saturday, but if I work Tuesday, I cannot work Thursday evening."
                       "I can work Monday through Wednesday mornings or Friday and Saturday evenings, but not both sets."
                       "I'm flexible with shifts on Monday, Wednesday, and Friday, but if I work Friday, I need Monday off."
                       "Available for any morning shifts on Monday, Tuesday, or Thursday, but if I work Tuesday, I cannot work Thursday morning."
                       "I can work late shifts on Wednesday and Thursday or early shifts on Friday and Saturday, but not both."
                       "Available for any shifts on Monday or Wednesday, but if I work Monday, I need Tuesday off completely."
                       "I can work any day except Tuesday, but if I work Thursday, I need either Monday or Wednesday off, but not both."
                       "Available for early shifts on Tuesday and Thursday, or late shifts on Wednesday and Friday, but not both."
                    "I can work any two of the following days: Monday Wednesday Thursday Friday." |#
                    ))

(define url "http://127.0.0.1:5000/generate")

(define (membero x lst)
  (conde
   [(== lst '()) (== 'f 't)]
   [(fresh (a ad)
           (== `(,a . ,ad) lst)
           (conde
            [(== x a)]
            [(membero x ad)]))]))

(define (schedulero e out)
  (fresh (a d z res)
         (conde
          [(== e '())
           (== out '())]
          [(== `(,a . ,d) e)
           (membero z a)
           (== `(,z . ,res) out)
           (schedulero d res)])))

;; ListOf String -> ListOf ListOf Symbol
;; Purpose: To query the LLM, convert the response into a list, and return a list of all the responses
(define (get-availabilities a-los)
  (local [;; String -> Json
          ;; Purpose: Query the LLM host at *url*
          (define (get-res prompt)
            (response-json
             (post url
                   #:json (hasheq 'prompt prompt)
                   #:timeouts (make-timeout-config
                               #:lease 5
                               #:connect 5
                               #:request 1000))))

          ;; String -> List
          ;; Converts the string result from the LLM into a list
          (define (string->list str)
            (read (open-input-string str)))]
    (cond
      [(empty? a-los) '()]
      [else (cons (string->list                                  ;; conversion
                   (hash-ref (get-res (first a-los)) 'response)) ;; getting actual response string
                   (get-availabilities (rest a-los)))])))        ;; recursive call

(define availabilities (get-availabilities texts))
(define results (run* (q) (schedulero availabilities q)))
results
(check-expect (length results) (foldl (λ (i accum) (* (length i) accum)) 1 availabilities))

