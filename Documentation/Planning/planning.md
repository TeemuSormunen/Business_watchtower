# Business Watchtower

## Contents

1. [Introduction and overview](#introduction-and-overview)

2. [Objectives](#objectives)

3. [User Stories](#user-stories)

4. [Use Case](#use-case)

5. [Mock-up and usage workflow](#mock-up-and-usage-workflow)

6. [UML](#uml)

7. [Time and workload planning](#time-and-workload-planning)

## Introduction and overview

This document contains plans for Mobile Project course, where the mission was to do a research on technology called Flutter.
Flutter is an open source cross-platform technology for mobile devices developed by google. Besides on just doing a research, additional
objective is to create an app by using this technology to gain deeper knowledge and understand how everything works and how
it feels to use it. The app created for this is called Business watchtower.

Business watchtower is a cross-platform mobile app designed to meet the needs of a person
who wants to keep track of what's happening with the currencies, crypto-currencies and stock markets.

Currently there is a prototype which can display info about aforementioned topics. This prototype was created
for Mobile Application Development course and it pretty much achieved what was wanted from it for that course.
The goal here is to expand that prototype by adding new features, which are explained in next chapter.

## Objectives

Main objectives are of course to get more familiar with Flutter and to create a better version of Business watchtower.
Team has decided to achieve these objectives by defining smaller and more precise objectives. First three objectives are
top priority and should be achieved no matter what. The rest are bonus which are done afterwards

1. Finding stocks, cryptos and currencies

   Currently the app shows data only about pre-defined stocks and currencies and the user has no input on what data is shown.
   That needs be changed so that user can search stocks and choose which companies stocks are shown in the app. Preferably this
   should be achieved so that if new companies come to the markets, their stocks are also shown in the search, so no hardcoded list,
   or if there is a list, it gets updated programmatically.

2. Graphs

   What people interested in investing love more than graphs? Probably nothing, so the app has to show the price development to the user.
   This is meant to be done by using some external library which draws graph based on data given to it, but the research process for this
   is still in works.

3. Better layout

   Currently app isn't as ugly as it could be, but it can always be better. That's way the layout needs to be reworked so it looks more
   profesional and it also supports new features.

4. Favorite system

   When thinking product like this, most of the time people probably would only want to see how certain stocks or crypto-currencies are doing
   instead of going through a long list. That's why the app should have a favorite system where user could choose few of the most important
   stocks/currencies and those would be shown on the main screen. That way the user could launch the app, see immediately what's been happening
   and close the app if that's all the info needed.
   

## User Stories

Point of these user stories is to make the reader of this document to understand
what needs is this app supposed to meet.

- As a user I want to see what is happening in the stock markets.

- As a user I want to see current currency rates.

- As a user I want to see current crypto-currency rates.

- As a user I want to be able to search which stocks are shown.

- As a user I want to be able to select favorite stocks, currencies and cryptocurrencies.

- As a user I want that first things I see in the app are favorited items.

- As a user I want to see graphs based on the value change.

- As a user I want to see more detailed data about stocks, currencies and cryptocurrencies by selecting one of them.


## Use Case

This use case tries to give some insight how the app works and it meets the needs of the user.
App gets almost all data the user sees from outside sources, which are then handled and shown
to the user in a more pleasant way. User can also make selections about what he wants to see
and based on those selections, data is retrieved with the arguments selected by the user.

<br>

![Use Case](/Documentation/Images/UseCaseDiagram.png)*Use Case diagram*

<br>

## Mock-up and usage workflow

Mock-up can be found here [https://ninjamock.com/s/LNHQTSx](https://ninjamock.com/s/LNHQTSx)

## Time and workload planning

Hours marked in the table below are hours/person/week, so total amount put the project
is obtained by multiplying the hours by the number of team members (four). Time tracking
about the hours actually used in this project can be found on README.md.


| Week | Planned hours | Info |
|:---:|:---:|:---:|
| 46 | 7 | Planning, dividing tasks and starting the project |
| 47 | 10 | Efficient working and tasks divided as much as possible |
| 48 | 10 | Efficient working and tasks divided as much as possible |
| 49 | 10 | Efficient working and tasks divided as much as possible |
| 50 | 10 | Finalizing the product and presentation |