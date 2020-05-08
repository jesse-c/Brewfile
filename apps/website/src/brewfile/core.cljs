(ns brewfile.core
  (:require [reagent.dom :as reagent]
            [re-frame.core :as rf]
            [clojure.string :as str]))


;; -- Debugging aids ----------------------------------------------------------


(enable-console-print!)


;; -- Domino 1 - Event Dispatch -----------------------------------------------




;; -- Domino 2 - Event Handlers -----------------------------------------------


(defn seq-contains?
  [coll item]
  (> (.indexOf coll item) -1))

(rf/reg-event-db
 :initialize
 (fn [_ _]
   {:term ""
    :selected []}))

(rf/reg-event-db
 :term-change
 (fn [db [_ new-term-value]]
   (assoc db :term new-term-value)))

(rf/reg-event-db
 :term-select
 (fn [db [_ term]]
   (let [selected (:selected db)]
     (if-not (seq-contains? selected term)
       (assoc db :selected (conj selected term))
       db))))

(rf/reg-event-db
 :term-unselect
 (fn [db [_ term]]
   (let [selected (:selected db)]
     (if (seq-contains? selected term)
       (assoc db :selected (remove #(= % term) selected))
       db))))


;; -- Domino 4 - Query  -------------------------------------------------------


(rf/reg-sub
 :term
 (fn [db _]
   (:term db)))

(rf/reg-sub
 :selected
 (fn [db _]
   (:selected db)))

;; -- Domino 5 - View Functions ----------------------------------------------


(def brewfiles
  ["Core" "DNS" "Dev-Go" "Dev-HTTP" "Neovim" "Privacy" "Python" "Vim"])

(defn home-page-url [] "https://www.jesseclaven.com/")

(defn term-input
  []
  [:div
   [:input {:type "text"
            :value @(rf/subscribe [:term]),
            :on-change #(rf/dispatch [:term-change (-> % .-target .-value)])}]])

(defn term-selected
  []
  (let [selected @(rf/subscribe [:selected])]
    [:ul
     (for [x selected]
       [:li {:key (str "term-selected-" x), :on-click #(rf/dispatch [:term-unselect x])} x])]))

(defn term-chooser
  []
  (let [selected @(rf/subscribe [:selected])
        term @(rf/subscribe [:term])
        remaining (filterv #(str/includes? (str/lower-case %) (str/lower-case term))
                           (filterv #(not (seq-contains? selected %)) brewfiles))]
    [:ul]
    (for [x remaining]
      [:li {:key (str "term-chooser-" x), :on-click #(rf/dispatch [:term-select x])} x])))

(defn generate-button
  []
  [:a {:href @(rf/subscribe [:selected]), :role "button"} "Generate"])

(defn code-inline
  [content]
  [:code {:style {:background-color "#E5E5E5", :padding "3px"}} content])

(defn header
  []
  [:div {:style {:background-color "#000000",
                 :width "100%"
                 :height "40px",
                 :padding "0 10px",
                 :color "#FFFFFF",
                 :display "flex",
                 :align-items "center",
                 :font-size "14px"}}
   [:span "A project by " [:a {:href (home-page-url)} "Jesse Claven"] "."]])

(defn notice
  []
  [:div {:style {:background-color "#FFFE61",
                 :width "100%",
                 :height "40px",
                 :padding "0 10px",
                 :color "#000000",
                 :display "flex",
                 :align-items "center"}}
   [:span {:style {:background-color "#000000",
                   :color "#FFFFFF",
                   :padding "5px 7px",
                   :margin-right "10px",
                   :border-radius "3px",
                   :font-size "12px",
                   :font-weight "bold"}}
    "NEW!"]
   [:span {:style {:font-size "14px"}} "Welcome to Brewfiles—have a look through the introductory post."]])

(defn intro
  []
  [:dev
   [:h1 {:name "intro"} "Brewfiles"]
   [:p "Generate Brewfiles from existing templates."]])

(defn search
  []
  [:dev
   [:dev
    (term-input)
    (term-selected)
    (term-chooser)
    (generate-button)]])

(defn templates
  []
  [:div
   [:div
    [:h2 "Templates"]
    [:span (count brewfiles)]
    [:span [:a {:href "https://github.com/jesse-c/Brewfile"} "Add"]]]
   [:div
    [:ul
     (for [x brewfiles]
       [:li {:key (str "template-" x)} x])]]])

(defn instructions
  []
  [:div
   [:h2 "Instructions"]
   [:ol
    [:li "Install " [:a {:href "https://www.brew.sh"} "Homebrew"]]
    [:li "Install " [:a {:href "https://github.com/mas-cli/mas"} "mas"]]
    [:li "Generate a Brewfile and place it in your " (code-inline "$HOME")]
    [:li "Run " (code-inline "brew bundle")]]])

(def api-endpoints [{:desc "List all", :endpoint "list/$t1,$t2,$tX", :method "GET"}
                    {:desc "Search", :endpoint "search/$t1,$t2,$tX", :method "GET"}
                    {:desc "Generate", :endpoint "generate/$t1,$t2,$tX", :method "GET"}
                    {:desc "Help", :endpoint "", :method "GET"}])

(def base-endpoint "http://brewfile.io/api/")

(defn api
  []
  [:div
   [:h2 "API"]
   [:table
    [:tbody
     (for [x api-endpoints]
       [:tr {:key (str "api-endpoint-" x)}
        [:td (:desc x)]
        [:td (code-inline (:method x))]
        [:td (-> x (get :endpoint) (#(conj [base-endpoint] %)) (str/join) (code-inline))]])]]
   [:div "Where " (code-inline "$tX") " is a term, e.g. " (code-inline (rand-nth brewfiles)) "."]])

(defn notes
  []
  [:div
   [:span "Thank you to the people behind Homebrew and Gitignore.io."]
   [:span "View project source code."]])

(defn footer
  []
  [:div
   [:span [:a {:href "/#intro"} "↑ Top"]]
   [:span [:a {:href (home-page-url)} "Jesse Claven"]]])

(defn ui
  []
  [:div
   [header]
   [notice]
   [intro]
   [search]
   [:hr]
   [templates]
   [:hr]
   [instructions]
   [:hr]
   [api]
   [:hr]
   [notes]
   [:hr]
   [footer]])

;; -- Entry Point -------------------------------------------------------------

(defn render
  []
  (reagent/render [ui]
                  (js/document.getElementById "app")))

(defn ^:dev/after-load clear-cache-and-render!
  []
  ;; The `:dev/after-load` metadata causes this function to be called
  ;; after shadow-cljs hot-reloads code. We force a UI update by clearing
  ;; the Reframe subscription cache.
  (rf/clear-subscription-cache!)
  (render))

(defn ^:export init
  []
  (rf/dispatch-sync [:initialize])  ;; put a value into application state
  (render))                         ;; mount the application's ui into '<div id="app" />'
