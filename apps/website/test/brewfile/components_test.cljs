(ns brewfile.components-test
  (:require [cljs.test :refer [deftest testing is use-fixtures]]
            [brewfile.core :as core]
            [re-frame.core :as rf]
            [day8.re-frame.test :as rf-test]
            [reagent.core :as reagent]
            [reagent.dom.server :as rds]
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

;; Helper function to test components that return hiccup
(defn component-to-string [component]
  (-> component
      (reagent/as-element)
      (rds/render-to-string)))

;; ---- Component Tests ----

(deftest term-chooser-empty-test
  (testing "term-chooser-empty renders correctly"
    (let [html (component-to-string (core/term-chooser-empty))]
      (is (str/includes? html "<li><em>No matches</em></li>")))))

(deftest code-inline-test
  (testing "code-inline renders correctly"
    (let [html (component-to-string (core/code-inline "test-code"))]
      (is (str/includes? html "<code>test-code</code>")))))

(deftest header-test
  (testing "header includes link to author page"
    (let [html (component-to-string (core/header))]
      (is (str/includes? html "A project by"))
      (is (str/includes? html (core/home-page-url))))))

(deftest intro-test
  (testing "intro renders heading and description"
    (let [html (component-to-string (core/intro))]
      (is (str/includes? html "<h1"))
      (is (str/includes? html "Brewfile"))
      (is (str/includes? html "Generate a Brewfile")))))

(deftest templates-test
  (rf-test/run-test-sync
   (testing "templates shows all brewfiles"
     (let [html (component-to-string (core/templates))]
       (is (str/includes? html (str "(" (count core/brewfiles) ")")))
       (doseq [template core/brewfiles]
         (is (str/includes? html template)))))))

(deftest instructions-test
  (testing "instructions shows ordered list"
    (let [html (component-to-string (core/instructions))]
      (is (str/includes? html "<ol"))
      (is (str/includes? html "Homebrew"))
      (is (str/includes? html "mas"))
      (is (str/includes? html "brew bundle")))))

(deftest api-test
  (testing "api section shows all endpoints"
    (let [html (component-to-string (core/api))]
      (is (str/includes? html "<h2>API</h2>"))
      (is (str/includes? html "table"))
      (doseq [endpoint core/api-endpoints]
        (is (str/includes? html (:desc endpoint)))
        (is (str/includes? html (:method endpoint)))))))

(deftest footer-test
  (testing "footer includes top link and home link"
    (let [html (component-to-string (core/footer))]
      (is (str/includes? html "↑ Top"))
      (is (str/includes? html (core/home-page-url)))
      (is (str/includes? html "Jesse Claven")))))

;; ---- Integration Tests with re-frame state ----

(deftest term-input-integration-test
  (rf-test/run-test-sync
   (testing "term-input shows search box"
     (let [html (component-to-string (core/term-input))]
       (is (str/includes? html "search-input"))
       (is (str/includes? html "term-chooser")))))
   
  (rf-test/run-test-sync
   (testing "term-input shows all options when term is empty"
     (let [html (component-to-string (core/term-input))]
       (doseq [brewfile core/brewfiles]
         (is (str/includes? html brewfile))))))
  
  (rf-test/run-test-sync
   (rf/dispatch [:term-change "Co"])
   (testing "term-input filters options based on search term"
     (let [html (component-to-string (core/term-input))]
       (is (str/includes? html "Core"))
       (is (not (str/includes? html "Vim")))))))

(deftest term-selected-integration-test
  (rf-test/run-test-sync
   (testing "term-selected is empty initially"
     (let [html (component-to-string (core/term-selected))]
       (is (not (str/includes? html "Core"))))))
  
  (rf-test/run-test-sync
   (rf/dispatch [:term-select "Core"])
   (rf/dispatch [:term-select "DNS"])
   (testing "term-selected shows selected terms"
     (let [html (component-to-string (core/term-selected))]
       (is (str/includes? html "Core"))
       (is (str/includes? html "DNS"))))))

(deftest generate-button-integration-test
  (rf-test/run-test-sync
   (testing "generate-button has correct href when no selection"
     (let [html (component-to-string (core/generate-button))]
       (is (str/includes? html "href=\"/api/generate/\"")))))
  
  (rf-test/run-test-sync
   (rf/dispatch [:term-select "Core"])
   (rf/dispatch [:term-select "DNS"])
   (testing "generate-button href updates with selection"
     (let [html (component-to-string (core/generate-button))]
       (is (str/includes? html "href=\"/api/generate/Core,DNS\""))))))