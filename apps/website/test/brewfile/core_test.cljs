(ns brewfile.core-test
  (:require [cljs.test :refer [deftest testing is use-fixtures]]
            [brewfile.core :as core]
            [re-frame.core :as rf]
            [day8.re-frame.test :as rf-test]
            [clojure.string :as str]))

;; ---- Utilities for Testing ----

(defn fixture-re-frame
  "Sets up and tears down re-frame for testing"
  [f]
  (rf/clear-subscription-cache!)
  (rf-test/with-temp-re-frame-state
    (rf/dispatch-sync [:initialize])
    (f)))

(use-fixtures :each fixture-re-frame)

;; ---- Helper Function Tests ----

(deftest seq-contains-test
  (testing "seq-contains? returns true when item is in collection"
    (is (core/seq-contains? ["a" "b" "c"] "a"))
    (is (core/seq-contains? ["a" "b" "c"] "b"))
    (is (core/seq-contains? ["a" "b" "c"] "c")))
  
  (testing "seq-contains? returns false when item is not in collection"
    (is (not (core/seq-contains? ["a" "b" "c"] "d")))
    (is (not (core/seq-contains? [] "a"))))
  
  (testing "seq-contains? works with different types"
    (is (core/seq-contains? [1 2 3] 1))
    (is (not (core/seq-contains? [1 2 3] "1"))))
  
  (testing "seq-contains? with empty collection"
    (is (not (core/seq-contains? [] "anything")))))

(deftest selected-to-href-test
  (testing "selected-to-href creates correct URL"
    (is (= "/api/generate/Core" (core/selected-to-href ["Core"])))
    (is (= "/api/generate/Core,DNS" (core/selected-to-href ["Core" "DNS"])))
    (is (= "/api/generate/Core,DNS,Python" (core/selected-to-href ["Core" "DNS" "Python"]))))
  
  (testing "selected-to-href with empty list"
    (is (= "/api/generate/" (core/selected-to-href [])))))

;; ---- Event Tests ----

(deftest initialize-test
  (testing "initialize event sets up empty db correctly"
    (rf-test/run-test-sync
     (let [app-db @(rf/subscribe [:app-db])]
       (is (= "" (:term app-db)))
       (is (= [] (:selected app-db)))
       (is (= false (:search-focused app-db)))
       (is (= false (:terms-focused app-db)))))))

(deftest term-change-test
  (testing "term-change event updates term in db"
    (rf-test/run-test-sync
     (rf/dispatch [:term-change "Co"])
     (is (= "Co" @(rf/subscribe [:term]))))))

(deftest term-select-test
  (testing "term-select adds term to selected list"
    (rf-test/run-test-sync
     (rf/dispatch [:term-select "Core"])
     (let [selected @(rf/subscribe [:selected])]
       (is (= ["Core"] selected))
       (is (core/seq-contains? selected "Core")))))
  
  (testing "term-select doesn't add duplicates"
    (rf-test/run-test-sync
     (rf/dispatch [:term-select "Core"])
     (rf/dispatch [:term-select "Core"])
     (is (= ["Core"] @(rf/subscribe [:selected]))))))

(deftest term-unselect-test
  (testing "term-unselect removes term from selected list"
    (rf-test/run-test-sync
     (rf/dispatch [:term-select "Core"])
     (rf/dispatch [:term-select "DNS"])
     (rf/dispatch [:term-unselect "Core"])
     (let [selected @(rf/subscribe [:selected])]
       (is (= ["DNS"] selected))
       (is (not (core/seq-contains? selected "Core"))))))
  
  (testing "term-unselect does nothing for non-selected terms"
    (rf-test/run-test-sync
     (rf/dispatch [:term-select "Core"])
     (rf/dispatch [:term-unselect "Python"])
     (is (= ["Core"] @(rf/subscribe [:selected]))))))

(deftest focus-tests
  (testing "search-focus and search-unfocus events"
    (rf-test/run-test-sync
     (rf/dispatch [:search-focus])
     (is (true? @(rf/subscribe [:search-focused])))
     
     (rf/dispatch [:search-unfocus])
     (is (false? @(rf/subscribe [:search-focused])))))
  
  (testing "terms-focus and terms-unfocus events"
    (rf-test/run-test-sync
     (rf/dispatch [:terms-focus])
     (is (true? @(rf/subscribe [:terms-focused])))
     
     (rf/dispatch [:terms-unfocus])
     (is (false? @(rf/subscribe [:terms-focused]))))))

;; ---- Subscription Tests ----

(deftest subscription-tests
  (testing "term subscription"
    (rf-test/run-test-sync
     (rf/dispatch [:term-change "test"])
     (is (= "test" @(rf/subscribe [:term])))))
  
  (testing "selected subscription"
    (rf-test/run-test-sync
     (rf/dispatch [:term-select "Core"])
     (rf/dispatch [:term-select "DNS"])
     (is (= ["Core" "DNS"] @(rf/subscribe [:selected])))))
  
  (testing "search-focused subscription"
    (rf-test/run-test-sync
     (rf/dispatch [:search-focus])
     (is (true? @(rf/subscribe [:search-focused])))))
  
  (testing "terms-focused subscription"
    (rf-test/run-test-sync
     (rf/dispatch [:terms-focus])
     (is (true? @(rf/subscribe [:terms-focused]))))))