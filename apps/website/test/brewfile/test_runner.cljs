(ns brewfile.test-runner
  (:require
   [cljs.test :refer-macros [run-tests]]
   [brewfile.core-test]
   [brewfile.components-test]
   [brewfile.render-test]))

(defn ^:export init []
  (run-tests
   'brewfile.core-test
   'brewfile.components-test
   'brewfile.render-test))