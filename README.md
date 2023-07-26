# 10ex.dev Take Home Project

This was a takehome technical assignment that I completed for 10ex.dev.
In short, the challenge was to implement a set of common features within a Phoenix app in under 4 hours.
This is my solution to that challenge. I've written my reasoning behind each of my choices beneath each
of the goals listed below.

> **Note**
> There is nothing special about this application,
> so if you get stuck you can always have a look at the [official Phoenix docs](https://hexdocs.pm/phoenix/1.7.1/installation.html).

## Assignment

This assignment consists of 9 different steps, that are functionally related,and build upon each other.
For this assignment you have to clone this repository,
get the application running locally and then work on the code,
as you would with any other Elixir/Phoenix application.

### What is and isn't expected

- We don't expect you to complete all the steps.
The main goal of the assignment is to have some code we can talk about in our next call.
We don't want to use more of your free time than absolutely necessary.
The assignment is intended to take **up to 4 hours**, but not more.

- You do not need to do the steps in the exact order they are listed.

- The application should work out of the box.
No show-stopper kind of programming errors have been intentionally added to it.
However, we expect you to **fix any application/logic errors** that you come across.
We would love to discuss them in our next call.

- We expect you to do **local refactorings and small code improvements** as you see fit.
However, do not focus on the HTML/CSS/JS part of the application, unless absolutely necessary.
This is an Elixir assignment after all.

- Last but not least we expect you to **use Git** during the assignment.
Put your changes into appropriately sized commits,
just as if you were working in a collaborative environment. We will review these commits and 
changes as part of the pair review session. 


## Goals
  1. Fetch the characters from the Marvel API. Hint: You will use the URL
  http://gateway.marvel.com/v1/public/characters?[authenticated_params]

  *Solution*   

   The most complex part of querying this api is creating a hash from the public and private keys using md5 encoding.
   This I achieved using erlangs kernel level helper function for such hashing.
   Reading through this API's documentation, I found that they implement the etag attribute for their resources. 
   The etag is a type of version indicator that would make caching much simpler as I move through the objectives.

  2. Render the characters' names in a list on the UI with LiveView or via a controller and view.
    
    *Solution* 
    
      Creating an unordered list view with LiveView was the fastest way achieve this goal.

  3. This is slow, every time we load the page, we need to fetch all the data again from the Marvel
  API. Let's implement a cache that stores this API call in memory so we don't need to keep
  fetching it on each page reload.

  *Solution*

    The dependency-free way to implement caching in Elixir is to start an ETS (erlang term storage) table
    within a GenServer. This way, values can be stored in memory, cleared after a specified period, and cleaned up
    when the GenServer terminates. However, I was concerned about time, so I opted for an existing Hex package that
    implements this functionality: Cachex. Cachex does exactly as I described above, but with straightforward Elixir
    functions.

    To cache the data, I use the etag attribute from the initial query to the Marvel API to create a key within 
    the Cachex cache where the value is our list of characters. Whenever a call is made to the Marvel API, I grab
    the current etag and pass it with the GET query. If my etag matches that of the specified resource I will recieve
    a 304 code, which is my queue to use the character data within the cache.

  4. Upper management really wants to know how often we are making requests to the Marvel API, so
  let's capture the timestamp of each successful API call into a database table.

  *Solution*

    This was a matter of generating a migration to store the data, writing a schema for the in-memory struct, and 
    writing necessary context functions. I felt that since this data is ostensibly for analysis, it would make 
    sense to only have read and write functionality. Since destroying or altering our records would compromise 
    the integrity of our data, I felt it best not to explicitly expose functions to do so.

    Whenever a successful (200 or 304) call is made to the Marvel API, I persist a record in the db, recording 
    the time, the resource's name, and the associated etag.

  5. You will notice that the API is only giving us the first 20 results when we call it. Let's implement a
  pagination system to allow the users to see additional results in the UI. How does this affect our cache? Should we change anything?

  *Solution*

    I implemented pagination by creating a form in the LiveView view that allows users to input how many characters
    they would like to see. When submitted, this number is updated on the socket. Also saved on the socket is the current "page",
    which in this case is an abstract representation of the users position within the list of characters. When a rerender of the page
    is triggered a subsequent call is made to the Marvel API. I multiply the current page value by the results per page to determine
    the offset, and the results-per-page value to determine the limit. This results in a smooth progression through the list of characters.

    I also implemented "next" and "previous" buttons to move forward or back through the list of characters to illustrate this feature.

  6. Let's add more test coverage. We want to mock the API calls, test the front end results, unit test
  the api authentication code, etc.

  *Solution*

    At this point of the challenge I felt I was running low on time, and so only had time to implement one test. I chose to test the
    happy path return value of get_all_characters/2. To do this, I added ExVCR as a dependency. This package allows me to record and 
    mock initial API calls made during tests so such calls do not need to be made every time the test suite is run. ExVCR works by 
    checking if a VCR (a json file of the API response) of the specified name exists. If it does not, then ExVCR makes the request
    and creates a file to store the response for subsequent tests. 

  7. What are some ways that we can improve the current code we just wrote? Think through the following:
  - Cache improvements (invalidation, pre-fetching, data optimization, handling api call failures, etc).
  - Improvements to the API interface.

  *Thoughts on improvements*

    If I had more time I would improve my solution by:
      - Handling server errors by serving what data we had in the cache, if any
      - Recording additional VCRs of other potential responses and testing for those cases (e.g. 500 errors)
      - Designing the view in such a way as to limit the variation in results-per-page. Etags change based
        on the number of results requested, and so the cache could be storing every variation between 1 and N,
        which is inefficient. Limiting the results to common intervals (i.e. 10, 100, 1000, etc.) would prevent this.
    

8. Now let's deploy this to fly.io. It is free to make an account and deploy a starter application. Follow their [getting started guide](https://fly.io/docs/elixir/getting-started/existing/).
  You can find this project deployed live here: https://stefan-sahagian-ten-ex-take-home.fly.dev/characters