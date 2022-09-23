;;; 870084 Hu Stefano Yecheng

(defun uri-parse (uristring)
  (let ((urilist (substi '%20 #\Space (coerce uristring 'list))))
    (let ((lscheme (scheme-presence urilist)))
      (let ((boolscheme (caddr lscheme)))
	(let ((boolsscheme
	       (car (special-scheme-presence (car lscheme) boolscheme)))
	      (bss
	       (cadr (special-scheme-presence (car lscheme) boolscheme)))
	      (boolauth
	       (cadr (authority-presence (cadr lscheme)))))
	  (cond
	   ((null urilist) NIL)
	   ((mailto-presence (car lscheme) (cadr lscheme) boolsscheme)
	    (let ((mailto
		   (mailto-presence (car lscheme) (cadr lscheme) boolsscheme)))
	      (let ((luserinfo (list (car mailto))) (lhost (cdr mailto)))
		(if (and
		     (scheme-check (car lscheme))
		     (userinfo-check (car luserinfo))
		     (host-check (car lhost)))
		    (generate-uri lscheme
				  luserinfo
				  lhost
				  '((#\8 #\0))
				  NIL
				  NIL
				  NIL)))))
	   ((news-presence (car lscheme) (cadr lscheme) boolsscheme)
	    (let ((lhost
		   (news-presence (car lscheme) (cadr lscheme) boolscheme)))
	      (if (and
		   (host-check (car lhost))
		   (scheme-check (car lscheme)))
		  (generate-uri lscheme
				NIL
				lhost
				'((#\8 #\0))
				NIL
				NIL
				NIL))))
	   ((tel-fax-presence (car lscheme) (cadr lscheme) boolscheme)
	    (let ((luserinfo
		   (tel-fax-presence (car lscheme)(cadr lscheme) boolscheme)))
	      (if (and
		   (scheme-check (car lscheme))
		   (userinfo-check (car luserinfo)))
		  (generate-uri lscheme
				luserinfo
				NIL
				'((#\8 #\0))
				NIL
				NIL
				NIL))))
	   ((= bss 0)
	    (let ((rest (car (authority-presence (cadr lscheme)))))
	      (let ((luserinfo (userinfo-presence rest boolauth)))
		(let ((lfragment (fragment-presence (cadr luserinfo))))
		  (let ((lquery (query-presence (cadr lfragment))))
		    (let ((lpath (path-presence (cadr lquery)
						(car lquery)
						(car lfragment)
						boolauth)))
		      (let ((lport (port-presence (cadr lpath))))
			(let ((lhost (host-presence (cadr lport) boolauth)))
			  (if (and
			       (scheme-check (car lscheme))
			       (userinfo-check (car luserinfo))
			       (host-check (car lhost))
			       (port-check (car lport))
			       (path-check (car lscheme) (car lpath))
			       (path-zos-check (car lscheme) (car lpath))
			       (query-check (car lquery))
			       (fragment-check (car lfragment)))
			      (generate-uri lscheme
					    luserinfo
					    lhost
					    lport
					    lpath
					    lquery
					    lfragment))))))))))))))))

;; uri structure

(defstruct uri
  scheme
  userinfo
  host
  port
  path
  query
  fragment)

(defun generate-uri (lscheme luserinfo lhost lport lpath lquery lfragment)
  (let ((scheme (list-to-string (car lscheme)))
	(userinfo (list-to-string (car luserinfo)))
	(host (list-to-string (car lhost)))
	(port (parse-integer (list-to-string (car lport))))
	(path (list-to-string (car lpath)))
	(query (list-to-string (car lquery)))
	(fragment (list-to-string (car lfragment))))
    (make-uri
     :scheme scheme
     :userinfo userinfo
     :host host
     :port port
     :path path
     :query query
     :fragment fragment)))

;; functions for controlling lists

(defun copy-to-end (lst end)
  (if (zerop end)
      NIL
    (cons (car lst) (copy-to-end (cdr lst) (1- end)))))

(defun sublst (lst start &optional (end (length lst)))
  (if (zerop start)
      (copy-to-end lst end)
    (sublst (cdr lst) (1- start) (1- end))))

(defun split (lst index)
  (list (sublst lst 0 index) (sublst lst index)))

(defun search-element (lst element)
  (if (memb element lst)
      (- (length lst) (length (memb element lst)))))

(defun split-on-element (lst element)
  (if (search-element lst element)
      (split lst (search-element lst element))))

(defun list-to-string (lst)
  (if (not (null lst))
      (format nil "~{~A~}" lst)))

(defun equal-last (lst el)
  (cond ((null lst) NIL)
	((and (= (length lst) 1) (equal (car lst) el))
	 t)
	((not (equal (car lst) el))
	 (equal-last (cdr lst) el))))

(defun substi (el1 el2 lst)
  (if (memb el2 lst)
      (progn
	(let ((split-lst (split-on-element lst el2)))
	  (let ((new-lst
		 (append
		  (car split-lst)
		  (list el1)
		  (sublst (cadr split-lst) 1))))
	    (substi el1 el2 new-lst))))
    (values lst)))

(defun memb (el lst)
  (cond
   ((null lst) NIL)
   ((equal (car lst) el) (values lst))
   ((not (equal (car lst) el)) (memb el (cdr lst)))))

;; functions to check the presence of the various uri parts

(defun scheme-presence (lst)
  (if (memb #\: lst)
      (progn
	(if (not (equal #\: (car lst)))
	    (progn
	      (let ((split-lst (split-on-element lst #\:)))
		(list
		 (car split-lst)
		 (sublst (cadr split-lst) 1)
		 1)))
	  (error "No scheme")))
    (error "No scheme!")))

(defun authority-presence (lst)
  (if (and (equal #\/ (car lst)) (equal #\/ (cadr lst)))
      (list (sublst lst 2) 1)
    (list lst 0)))

(defun userinfo-presence (lst boolauth)
  (cond
   ((= boolauth 0) (list NIL lst))
   ((and (not (memb #\@ lst)) (= boolauth 1)) (list NIL lst))
   ((and (memb #\@ lst) (= boolauth 1))
    (let ((split-lst (split-on-element lst #\@)))
      (if (not (null (car split-lst)))
	  (list (car split-lst) (sublst (cadr split-lst) 1))
	(error "userinfo syntax error"))))))

(defun host-presence (lst boolauth)
  (cond
   ((= boolauth 0) NIL)
   ((and
     (= boolauth 1)
     (null lst))
    (error "host can't be null if the authorithy is present"))
   ((= boolauth 1)
    (list lst))))

(defun port-presence (lst)
  (cond
   ((not (memb #\: lst)) (list '(#\8 #\0) lst))
   ((memb #\: lst)
    (let ((split-lst (split-on-element lst #\:)))
      (if (not (null (sublst (cadr split-lst) 1)))
	  (list (sublst (cadr split-lst) 1) (car split-lst))
	(error "port error"))))))

(defun path-presence (lst lquery lfragment boolauth)
  (cond
   ((and
     (not (memb #\/ lst))
     (= boolauth 1)
     (or (not (null lquery)) (not (null lfragment))))
    (error "syntax error"))
   ((and (= boolauth 1) (not (memb #\/ lst)))
    (list NIL lst))
   ((and (= boolauth 1) (memb #\/ lst))
    (let ((split-lst (split-on-element lst #\/)))
      (list (sublst (cadr split-lst) 1) (car split-lst))))
   ((and
     (= boolauth 0)
     (not (null lst))
     (not (equal (car lst) #\/)))
    (error "syntax error"))
   ((and
     (= boolauth 0)
     (or
      (not (null lquery))
      (not (null lfragment)))
     (not (equal (car lst) #\/)))
    (error "syntax error"))
   ((and
     (= boolauth 0)
     (null lquery)
     (null lfragment)
     (null lst))
    (list NIL NIL))
   ((and (= boolauth 0) (equal #\/ (car lst)))
    (list (sublst lst 1)))))

(defun query-presence (lst)
  (cond
   ((not (memb #\? lst)) (list NIL lst))
   ((memb #\? lst)
    (let ((split-lst (split-on-element lst #\?)))
      (if (not (null (sublst (cadr split-lst) 1)))
	  (list (sublst (cadr split-lst) 1) (car split-lst)))))))

(defun fragment-presence (lst)
  (cond
   ((not (memb #\# lst)) (list NIL lst))
   ((memb #\# lst)
    (let ((split-lst (split-on-element lst #\#)))
      (if (not (null (sublst (cadr split-lst) 1)))
	  (list (sublst (cadr split-lst) 1) (car split-lst)))))))

;; functions to check if the scheme is a special scheme

(defun special-scheme-presence (lscheme boolscheme)
  (cond
   ((and
     (not (equalp lscheme '(#\m #\a #\i #\l #\t #\o)))
     (not (equalp lscheme '(#\n #\e #\w #\s)))
     (not (equalp lscheme '(#\t #\e #\l)))
     (not (equalp lscheme '(#\f #\a #\x)))
     (not (equalp lscheme '(#\z #\o #\s))))
    (list 0 0))
   ((and (= boolscheme 1) (or
			   (equalp lscheme '(#\m #\a #\i #\l #\t #\o))
			   (equalp lscheme '(#\n #\e #\w #\s))
			   (equalp lscheme '(#\t #\e #\l))
			   (equalp lscheme '(#\f #\a #\x))
			   ))
    (list 1 1))
   ((and (= boolscheme 1) (equalp lscheme '(#\z #\o #\s)))
    (list 1 0))))

;; functions to check which special scheme it is

(defun mailto-presence (lscheme lst boolsscheme)
  (cond
   ((= boolsscheme 0) NIL)
   ((and
     (= boolsscheme 1)
     (not (equalp lscheme '(#\m #\a #\i #\l #\t #\o))))
    NIL)
   ((and
     (= boolsscheme 1)
     (equalp lscheme '(#\m #\a #\i #\l #\t #\o)))
    (if (memb #\@ lst)
	(progn
	  (let ((split-lst (split-on-element lst #\@)))
	    (if (and (not (null (car split-lst)))
		     (not (null (sublst (cadr split-lst) 1))))
		(list (car split-lst) (sublst (cadr split-lst) 1)))))
      (list lst)))))

(defun news-presence (lscheme lst boolsscheme)
  (cond
   ((= boolsscheme 0) NIL)
   ((and
     (= boolsscheme 1)
     (not (equalp lscheme '(#\n #\e #\w #\s))))
    NIL)
   ((and
     (= boolsscheme 1)
     (equalp lscheme '(#\n #\e #\w #\s)))
    (list lst))))

(defun tel-fax-presence (lscheme lst boolsscheme)
  (cond
   ((= boolsscheme 0) NIL)
   ((and
     (= boolsscheme 1)
     (not
      (or
       (equalp lscheme '(#\t #\e #\l))
       (equalp lscheme '(#\f #\a #\x)))))
    NIL)
   ((and
     (= boolsscheme 1)	  
     (or
      (equalp lscheme '(#\t #\e #\l))
      (equalp lscheme '(#\f #\a #\x))))
    (list lst))))

(defun path-zos-check (lscheme lpath)
  (cond
   ((not (equalp lscheme '(#\z #\o #\s))) t)
   ((equalp lscheme '(#\z #\o #\s))
    (cond
     ((null lpath) (error "zos-path can't be empty"))
     ((or
       (and (memb #\( lpath) (not (memb #\) lpath)))
       (and (memb #\) lpath) (not (memb #\( lpath))))
      (error "path-zos grammar error"))
     ((and
       (not (memb #\( lpath))
       (not (memb #\) lpath)))
      (id44-check lpath))
     ((and
       (memb #\( lpath)
       (memb #\) lpath))
      (let ((split-lst (split-on-element lpath #\()))
	(if (not (null (car split-lst)))
	    (progn
	      (id44-check (car split-lst))
	      (let ((split-lst2
		     (split-on-element (sublst (cadr split-lst) 1) #\))))   
		(if (not (null (car split-lst2)))
		    (id8-check (car split-lst2))))))))))))

;; functions to check zos-path grammar

(defun id44-check (lst)
  (cond
   ((equal (car lst) #\.) (error "id44 error"))
   ((not (alpha-char-p (car lst))) (error "id44 error"))
   ((and
     (<= (length lst) 44)
     (>= (length lst) 1))
    (if (id44-2-check lst)
	t
      (error "id44 error")))
   (t (error "id44 error"))))

(defun id44-2-check (lst)
  (cond
   ((null lst) t)
   ((and
     (= (length lst) 1)
     (equal (car lst) #\.))
    (error "id44 error"))
   ((or
     (alphanumericp (car lst))
     (equal (car lst) #\.))
    (id44-2-check (cdr lst)))
   (t (error "alphanumeric error"))))

(defun id8-check (lst)
  (cond
   ((not (alpha-char-p (car lst))) (error "id8 error"))
   ((and
     (>= (length lst) 1)
     (<= (length lst) 8))
    (if (id8-2-check lst)
	t
      (error "id8 error")))
   (t (error "id8 error"))))

(defun id8-2-check (lst)
  (cond
   ((null lst) t)
   ((alphanumericp (car lst))
    (id8-2-check (cdr lst)))
   (t (error "id8 error"))))

;; functions to check the grammar of the various uri parts

(defun scheme-check (lst)
  (if (id-check lst)
      t
    (error "scheme error")))

(defun userinfo-check (lst)
  (if (id-check lst)
      t
    (error "userinfo error")))

(defun host-check (lst)
  (cond
   ((or
     (equal-last lst #\.)
     (equal (car lst) #\.))
    (error "host error 1"))
   ((null lst) t)   
   ((not (memb #\. lst))	  
    (id-host-check lst))
   ((memb #\. lst)
    (if (ip-check lst)
	t
      (progn
	(let ((split-lst (split-on-element lst #\.)))
	  (id-host-check (car split-lst))
	  (host-check (sublst (cadr split-lst) 1))))))
   (t (error "host error 2"))))

(defun port-check (lst)
  (if (digit-check lst)
      t
    (error "port error")))

(defun path-check (lscheme lst)
  (cond   
   ((or
     (equal (car lst) #\/)
     (equal-last lst #\/))
    (error "path error"))
   ((equalp lscheme '(#\z #\o #\s)) t)
   ((null lst) t)
   ((not (memb #\/ lst))
    (id-check lst))
   ((memb #\/ lst)
    (let ((split-lst (split-on-element lst #\/)))
      (id-check (car split-lst))
      (path-check lscheme (subseq (cadr split-lst) 1))))))

(defun query-check (lst)
  (cond
   ((null lst) t)
   ((not (equal (car lst) #\#))
    (query-check (cdr lst)))
   (t (error "query error"))))

(defun fragment-check (lst)
  (cond
   ((null lst) t)
   ((characterp (car lst))
    (fragment-check (cdr lst)))
   (t (error "fragment error"))))

;; functions for secondary grammar checks

(defun id-check (lst)
  (cond
   ((null lst) t)
   ((and
     (not (equal (car lst) #\/))
     (not (equal (car lst) #\?))
     (not (equal (car lst) #\#))
     (not (equal (car lst) #\@))
     (not (equal (car lst) #\:)))
    (id-check (cdr lst)))
   (t (error "id error"))))

(defun id-host-check (lst)
  (cond
   ((null lst) t)
   ((and
     (not (equal (car lst) #\.))
     (not (equal (car lst) #\/))
     (not (equal (car lst) #\?))
     (not (equal (car lst) #\#))
     (not (equal (car lst) #\@))
     (not (equal (car lst) #\@)))
    (id-host-check (cdr lst)))
   (t (error "id-host error"))))

(defun digit-check (lst)
  (cond
   ((null lst) t)
   ((digit-char-p (car lst))
    (let ((digit (digit-char-p (car lst))))
      (if (and (>= digit 0) (<= digit 9))
	  (digit-check (cdr lst))
	(error "digit error"))))))

(defun three-digits-check (lst)
  (if (and
       (= (length lst) 3)
       (digit-check lst))
      (progn
	(let ((first (digit-char-p (car lst)))
	      (second (digit-char-p (cadr lst)))
	      (third (digit-char-p (caddr lst))))
	  (let ((n (+ (* first 100) (* second 10) third)))
	    (if (and (>= n 0) (<= n 255))
		t
	      (error "three-digits error")))))
    NIL))

(defun ip-check (lst)
  (if (= (length lst) 11)
      (ip-sub-check lst)
    NIL))

(defun ip-sub-check (lst)
  (cond
   ((null lst) t)
   ((not (memb #\. lst)) NIL)
   ((three-digits-check lst) t)	
   ((memb #\. lst)
    (let ((split-lst (split-on-element lst #\.)))
      (three-digits-check (car split-lst))
      (ip-sub-check (sublst (cadr split-lst) 1))))
   (t (error "ip-sub-check error"))))

;; function for displaying uri-structure

(defun uri-display (uri-structure &optional (stream t))
  (if (not (null uri-structure))
      (progn
	(format stream "Scheme:~d~d~d~%" #\tab #\tab (uri-scheme uri-structure))
	(format stream "Userinfo:~d~d~%" #\tab (uri-userinfo uri-structure))
	(format stream "Host:~d~d~s~%" #\tab #\tab (uri-host uri-structure))
	(format stream "Port:~d~d~d~%" #\tab #\tab (uri-port uri-structure))
	(format stream "Path:~d~d~s~%" #\tab #\tab(uri-path uri-structure))
	(format stream "Query:~d~d~s~%" #\tab #\tab (uri-query uri-structure))
	(format stream "Fragment:~d~s~%" #\tab (uri-fragment uri-structure))
	t)
    NIL))
