(ns brewfile.render-test
  (:require [cljs.test :refer [deftest testing is use-fixtures async]]
            [brewfile.core :as core]
            [reagent.core :as reagent]
            [re-frame.core :as rf]
            [day8.re-frame.test :as rf-test]
            [clojure.string :as str]
            ["react-dom/client" :as react-dom-client]))

;; ---- Utilities for Testing ----

(defn fixture-re-frame
  "Sets up and tears down re-frame for testing"
  [f]
  (rf/clear-subscription-cache!)
  (rf-test/with-temp-re-frame-state
    (rf/dispatch-sync [:initialize])
    (f)))

(use-fixtures :each fixture-re-frame)

;; ---- Rendering Tests ----

(deftest root-atom-test
  (testing "root-atom is initially nil"
    (core/render) ; First render will set the atom, but in tests we don't have a DOM
    (is (not (nil? @core/root-atom)))))

(deftest clear-cache-and-render-test
  (testing "clear-cache-and-render! clears subscription cache"
    (let [spy-called (atom false)
          orig-clear-subscription-cache rf/clear-subscription-cache!]
      (with-redefs [rf/clear-subscription-cache! (fn [] 
                                                  (reset! spy-called true)
                                                  (orig-clear-subscription-cache))]
        (core/clear-cache-and-render!)
        (is @spy-called)))))

(deftest init-test
  (testing "init function dispatches initialize event"
    (let [dispatched (atom nil)]
      (with-redefs [rf/dispatch-sync (fn [event]
                                      (reset! dispatched event))]
        (core/init)
        (is (= [:initialize] @dispatched))))))

;; Test React 18+ rendering patterns
(deftest render-function-test
  (testing "render creates root only once"
    (reset! core/root-atom nil)

    (let [create-root-called (atom 0)
          render-called (atom 0)
          mock-root (atom {:render (fn [_] (swap! render-called inc))})]

      (with-redefs [react-dom-client/createRoot (fn [_]
                                                 (swap! create-root-called inc)
                                                 @mock-root)]
        ;; First render should create root and call render
        (core/render)
        (is (= 1 @create-root-called))
        (is (= 1 @render-called))

        ;; Second render should reuse root and call render again
        (core/render)
        (is (= 1 @create-root-called))
        (is (= 2 @render-called))))))