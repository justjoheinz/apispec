(defpackage #:apispec/body
  (:use #:cl
        #:apispec/body/json
        #:apispec/body/urlencoded
        #:apispec/body/multipart)
  (:import-from #:apispec/utils
                #:detect-charset
                #:slurp-stream)
  (:import-from #:babel)
  (:import-from #:alexandria
                #:starts-with-subseq)
  (:export #:parse-body))
(in-package #:apispec/body)

(defun parse-body (value content-type)
  (check-type value (or string stream))
  (check-type content-type string)
  (let ((content-type (string-downcase content-type)))
    (cond
      ((starts-with-subseq "application/json" content-type)
       (etypecase value
         (string (parse-json-string value content-type))
         (stream (parse-json-stream value content-type))))
      ((starts-with-subseq "application/x-www-form-urlencoded" content-type)
       (etypecase value
         (string (parse-urlencoded-string value))
         (stream (parse-urlencoded-stream value))))
      ((starts-with-subseq "multipart/" content-type)
       (etypecase value
         (string (parse-multipart-string value content-type))
         (stream (parse-multipart-stream value content-type))))
      ((starts-with-subseq "application/octet-stream" content-type)
       (slurp-stream value))
      (t
       (babel:octets-to-string (slurp-stream value)
                               :encoding (detect-charset content-type))))))
