describe "DiscussionThreadListView", ->

    beforeEach ->
        DiscussionSpecHelper.setUpGlobals()
        setFixtures """
        <script type="text/template" id="thread-list-item-template">
          <li data-id="<%- id %>" class="forum-nav-thread<% if (typeof(read) != "undefined" && !read) { %> is-unread<% } %>">
            <a href="#" class="forum-nav-thread-link">
              <div class="forum-nav-thread-wrapper-1">
                <span class="forum-nav-thread-title"><%- title %></span>
                <%
                var labels = "";
                if (pinned) {
                    labels += '<li class="forum-nav-thread-label-pinned"><i class="icon icon-pushpin"></i>Pinned</li> ';
                }
                if (typeof(subscribed) != "undefined" && subscribed) {
                    labels += '<li class="forum-nav-thread-label-following"><i class="icon icon-star"></i>Following</li> ';
                }
                if (staff_authored) {
                    labels += '<li class="forum-nav-thread-label-staff"><i class="icon icon-user"></i>By: Staff</li> ';
                }
                if (community_ta_authored) {
                    labels += '<li class="forum-nav-thread-label-community-ta"><i class="icon icon-user"></i>By: Community TA</li> ';
                }
                if (labels != "") {
                    print('<ul class="forum-nav-thread-labels">' + labels + '</ul>');
                }
                %>
              </div><div class="forum-nav-thread-wrapper-2">
                <% if (endorsed) { %>
                  <span class="forum-nav-thread-endorsed"><i class="icon icon-ok"></i><span class="sr">Endorsed response</span></span>
                <% } %>
                <span class="forum-nav-thread-votes-count">+<%=
                    interpolate(
                        '%(votes_up_count)s%(span_sr_open)s votes %(span_close)s',
                        {'span_sr_open': '<span class="sr">', 'span_close': '</span>', 'votes_up_count': votes['up_count']},
                        true
                        )
                %></span>
                <span class="forum-nav-thread-comments-count <% if (unread_comments_count > 0) { %>is-unread<% } %>">
                    <%
                var fmt;
                var data = {
                    'span_sr_open': '<span class="sr">',
                    'span_close': '</span>',
                    'unread_comments_count': unread_comments_count,
                    'comments_count': comments_count
                    };
                if (unread_comments_count > 0) {
                    fmt = '%(comments_count)s %(span_sr_open)scomments (%(unread_comments_count)s unread comments)%(span_close)s';
                } else {
                    fmt = '%(comments_count)s %(span_sr_open)scomments %(span_close)s';
                }
                print(interpolate(fmt, data, true));
                %>
                </span>
              </div>
            </a>
          </li>
        </script>
        <script type="text/template" id="thread-list-template">
            <div class="forum-nav-header">
                <a href="#" class="forum-nav-browse" aria-haspopup="true">
                    <i class="icon icon-reorder"></i>
                    <span class="sr">Discussion topics; current selection is: </span>
                    <span class="forum-nav-browse-current">All Discussions</span>
                    ▾
                </a>
                <form class="forum-nav-search">
                    <label>
                        <span class="sr">Search</span>
                        <input class="forum-nav-search-input" type="text" placeholder="Search all posts">
                    </label>
                </form>
            </div>
            <div class="forum-nav-browse-menu-wrapper" style="display: none">
                <form class="forum-nav-browse-filter">
                    <label>
                        <span class="sr">Filter Topics</span>
                        <input type="text" class="forum-nav-browse-filter-input" placeholder="filter topics">
                    </label>
                </form>
                <ul class="forum-nav-browse-menu">
                    <li class="forum-nav-browse-menu-item forum-nav-browse-menu-all">
                        <a href="#" class="forum-nav-browse-title">All Discussions</a>
                    </li>
                    <li class="forum-nav-browse-menu-item forum-nav-browse-menu-flagged">
                        <a href="#" class="forum-nav-browse-title"><i class="icon icon-flag"></i>Flagged Discussions</a>
                    </li>
                    <li class="forum-nav-browse-menu-item forum-nav-browse-menu-following">
                        <a href="#" class="forum-nav-browse-title"><i class="icon icon-star"></i>Posts I'm Following</a>
                    </li>
                    <li class="forum-nav-browse-menu-item">
                        <a href="#" class="forum-nav-browse-title">Parent</a>
                        <ul class="forum-nav-browse-submenu">
                            <li class="forum-nav-browse-menu-item">
                                <a href="#" class="forum-nav-browse-title">Target</a>
                                <ul class="forum-nav-browse-submenu">
                                    <li
                                        class="forum-nav-browse-menu-item"
                                        data-discussion-id='{"sort_key": null, "id": "child"}'
                                        data-cohorted="false"
                                    >
                                        <a href="#" class="forum-nav-browse-title">Child</a>
                                    </li>
                                </ul>
                            <li
                                class="forum-nav-browse-menu-item"
                                data-discussion-id='{"sort_key": null, "id": "sibling"}'
                                data-cohorted="false"
                            >
                                <a href="#" class="forum-nav-browse-title">Sibling</a>
                            </li>
                        </ul>
                    </li>
                    <li
                        class="forum-nav-browse-menu-item"
                        data-discussion-id='{"sort_key": null, "id": "other"}'
                        data-cohorted="false"
                    >
                        <a href="#" class="forum-nav-browse-title">Other Category</a>
                    </li>
                </ul>
            </div>
            <div class="forum-nav-thread-list-wrapper">
                <div class="forum-nav-refine-bar">
                    <span class="forum-nav-sort">
                        <select class="forum-nav-sort-control">
                            <option value="date">by recent activity</option>
                            <option value="comments">by most activity</option>
                            <option value="votes">by most votes</option>
                        </select>
                    </span>
                </div>
            </div>
            <div class="search-alerts"></div>
            <ul class="forum-nav-thread-list"></ul>
        </script>
        <script aria-hidden="true" type="text/template" id="search-alert-template">
            <div class="search-alert" id="search-alert-<%- cid %>">
                <div class="search-alert-content">
                  <p class="message"><%- message %></p>
                </div>

                <div class="search-alert-controls">
                  <a href="#" class="dismiss control control-dismiss"><i class="icon icon-remove"></i></a>
                </div>
            </div>
        </script>
        <div class="sidebar"></div>
        """
        @threads = [
          makeThreadWithProps({
            id: "1",
            title: "Thread1",
            votes: {up_count: '20'},
            comments_count: 1,
            created_at: '2013-04-03T20:08:39Z',
          }),
          makeThreadWithProps({
            id: "2",
            title: "Thread2",
            votes: {up_count: '42'},
            comments_count: 2,
            created_at: '2013-04-03T20:07:39Z',
          }),
          makeThreadWithProps({
            id: "3",
            title: "Thread3",
            votes: {up_count: '12'},
            comments_count: 3,
            created_at: '2013-04-03T20:06:39Z',
          }),
        ]

        spyOn($, "ajax")

        @discussion = new Discussion([])
        @view = new DiscussionThreadListView({collection: @discussion, el: $(".sidebar")})
        @view.render()

    makeThreadWithProps = (props) ->
      # Minimal set of properties necessary for rendering
      thread = {
        id: "dummy_id",
        pinned: false,
        endorsed: false,
        votes: {up_count: '0'},
        unread_comments_count: 0,
        comments_count: 0,
      }
      $.extend(thread, props)

    renderSingleThreadWithProps = (props) ->
      makeView(new Discussion([new Thread(makeThreadWithProps(props))])).render()

    makeView = (discussion) ->
      return new DiscussionThreadListView(
          el: $(".sidebar"),
          collection: discussion
      )

    checkThreadsOrdering =  (view, sort_order, type) ->
      expect(view.$el.find(".forum-nav-thread").children().length).toEqual(3)
      expect(view.$el.find(".forum-nav-thread:nth-child(1) .forum-nav-thread-title").text()).toEqual(sort_order[0])
      expect(view.$el.find(".forum-nav-thread:nth-child(2) .forum-nav-thread-title").text()).toEqual(sort_order[1])
      expect(view.$el.find(".forum-nav-thread:nth-child(3) .forum-nav-thread-title").text()).toEqual(sort_order[2])
      expect(view.$el.find(".forum-nav-sort-control").val()).toEqual(type)

    describe "thread rendering should be correct", ->
        checkRender = (threads, type, sort_order) ->
            discussion = new Discussion(_.map(threads, (thread) -> new Thread(thread)), {pages: 1, sort: type})
            view = makeView(discussion)
            view.render()
            checkThreadsOrdering(view, sort_order, type)
            expect(view.$el.find(".forum-nav-thread-comments-count:visible").length).toEqual(if type == "votes" then 0 else 3)
            expect(view.$el.find(".forum-nav-thread-votes-count:visible").length).toEqual(if type == "votes" then 3 else 0)

        it "with sort preference date", ->
            checkRender(@threads, "date", [ "Thread1", "Thread2", "Thread3"])

        it "with sort preference votes", ->
            checkRender(@threads, "votes", [ "Thread2", "Thread1", "Thread3"])

        it "with sort preference comments", ->
            checkRender(@threads, "comments", [ "Thread3", "Thread2", "Thread1"])

    describe "Sort change should be correct", ->
      changeSorting = (threads, selected_type, new_type, sort_order) ->
        discussion = new Discussion(_.map(threads, (thread) -> new Thread(thread)), {pages: 1, sort: selected_type})
        view = makeView(discussion)
        view.render()
        sortControl = view.$el.find(".forum-nav-sort-control")
        expect(sortControl.val()).toEqual(selected_type)
        sorted_threads = []
        if new_type == 'date'
          sorted_threads = [threads[0], threads[1], threads[2]]
        else if new_type == 'comments'
          sorted_threads = [threads[2], threads[1], threads[0]]
        else if new_type == 'votes'
          sorted_threads = [threads[1], threads[0], threads[2]]
        $.ajax.andCallFake((params) =>
          params.success(
                {"discussion_data":sorted_threads, page:1, num_pages:1}
          )
          {always: ->}
        )
        sortControl.val(new_type).change()
        expect($.ajax).toHaveBeenCalled()
        checkThreadsOrdering(view, sort_order, new_type)

      it "with sort preference date", ->
          changeSorting(@threads, "comments", "date", ["Thread1", "Thread2", "Thread3"])

      it "with sort preference votes", ->
          changeSorting(@threads, "date", "votes", ["Thread2", "Thread1", "Thread3"])

      it "with sort preference comments", ->
          changeSorting(@threads, "votes", "comments", ["Thread3", "Thread2", "Thread1"])

    describe "search alerts", ->

        testAlertMessages = (expectedMessages) ->
            expect($(".search-alert .message").map( ->
              $(@).html()
            ).get()).toEqual(expectedMessages)

        it "renders and removes search alerts", ->
            testAlertMessages []
            foo = @view.addSearchAlert("foo")
            testAlertMessages ["foo"]
            bar = @view.addSearchAlert("bar")
            testAlertMessages ["foo", "bar"]
            @view.removeSearchAlert(foo.cid)
            testAlertMessages ["bar"]
            @view.removeSearchAlert(bar.cid)
            testAlertMessages []

        it "clears all search alerts", ->
            @view.addSearchAlert("foo")
            @view.addSearchAlert("bar")
            @view.addSearchAlert("baz")
            testAlertMessages ["foo", "bar", "baz"]
            @view.clearSearchAlerts()
            testAlertMessages []

    describe "search spell correction", ->

        beforeEach ->
            spyOn(@view, "searchForUser")

        testCorrection = (view, correctedText) ->
            spyOn(view, "addSearchAlert")
            $.ajax.andCallFake(
                (params) =>
                    params.success(
                        {discussion_data: [], page: 42, num_pages: 99, corrected_text: correctedText}, 'success'
                    )
                    {always: ->}
            )
            view.searchFor("dummy")
            expect($.ajax).toHaveBeenCalled()

        it "adds a search alert when an alternate term was searched", ->
            testCorrection(@view, "foo")
            expect(@view.addSearchAlert.callCount).toEqual(1)
            expect(@view.addSearchAlert.mostRecentCall.args[0]).toMatch(/foo/)

        it "does not add a search alert when no alternate term was searched", ->
            testCorrection(@view, null)
            expect(@view.addSearchAlert.callCount).toEqual(1)
            expect(@view.addSearchAlert.mostRecentCall.args[0]).toMatch(/no threads matched/i)

        it "clears search alerts when a new search is performed", ->
            spyOn(@view, "clearSearchAlerts")
            spyOn(DiscussionUtil, "safeAjax")
            @view.searchFor("dummy")
            expect(@view.clearSearchAlerts).toHaveBeenCalled()

        it "clears search alerts when the underlying collection changes", ->
            spyOn(@view, "clearSearchAlerts")
            spyOn(@view, "renderThread")
            @view.collection.trigger("change", new Thread({id: 1}))
            expect(@view.clearSearchAlerts).toHaveBeenCalled()

    describe "username search", ->

        it "makes correct ajax calls", ->
            $.ajax.andCallFake(
                (params) =>
                    expect(params.data.username).toEqual("testing-username")
                    expect(params.url.path()).toEqual(DiscussionUtil.urlFor("users"))
                    params.success(
                        {users: []}, 'success'
                    )
                    {always: ->}
            )
            @view.searchForUser("testing-username")
            expect($.ajax).toHaveBeenCalled()

        setAjaxResults = (threadSuccess, userResult) ->
            # threadSuccess is a boolean indicating whether the thread search ajax call should succeed
            # userResult is the value that should be returned as data from the username search ajax call
            $.ajax.andCallFake(
                (params) =>
                    if params.data.text and threadSuccess
                        params.success(
                            {discussion_data: [], page: 42, num_pages: 99, corrected_text: "dummy"},
                            "success"
                        )
                    else if params.data.username
                        params.success(
                            {users: userResult},
                            "success"
                        )
                    {always: ->}
            )

        it "gets called after a thread search succeeds", ->
            spyOn(@view, "searchForUser").andCallThrough()
            setAjaxResults(true, [])
            @view.searchFor("gizmo")
            expect(@view.searchForUser).toHaveBeenCalled()
            expect($.ajax.mostRecentCall.args[0].data.username).toEqual("gizmo")

        it "does not get called after a thread search fails", ->
            spyOn(@view, "searchForUser").andCallThrough()
            setAjaxResults(false, [])
            @view.searchFor("gizmo")
            expect(@view.searchForUser).not.toHaveBeenCalled()

        it "adds a search alert when an username was matched", ->
            spyOn(@view, "addSearchAlert")
            setAjaxResults(true, [{username: "gizmo", id: "1"}])
            @view.searchForUser("dummy")
            expect($.ajax).toHaveBeenCalled()
            expect(@view.addSearchAlert).toHaveBeenCalled()
            expect(@view.addSearchAlert.mostRecentCall.args[0]).toMatch(/gizmo/)

        it "does not add a search alert when no username was matched", ->
            spyOn(@view, "addSearchAlert")
            setAjaxResults(true, [])
            @view.searchForUser("dummy")
            expect($.ajax).toHaveBeenCalled()
            expect(@view.addSearchAlert).not.toHaveBeenCalled()

    describe "endorsed renders correctly", ->
      it "when absent", ->
        renderSingleThreadWithProps({})
        expect($(".forum-nav-thread-endorsed").length).toEqual(0)

      it "when present", ->
        renderSingleThreadWithProps({endorsed: true})
        expect($(".forum-nav-thread-endorsed").length).toEqual(1)

    describe "post labels render correctly", ->
      beforeEach ->
        @moderatorId = "42"
        @administratorId = "43"
        @communityTaId = "44"
        DiscussionUtil.loadRoles({
          "Moderator": [parseInt(@moderatorId)],
          "Administrator": [parseInt(@administratorId)],
          "Community TA": [parseInt(@communityTaId)],
        })

      it "for pinned", ->
        renderSingleThreadWithProps({pinned: true})
        expect($(".forum-nav-thread-label-pinned").length).toEqual(1)

      it "for following", ->
        renderSingleThreadWithProps({subscribed: true})
        expect($(".forum-nav-thread-label-following").length).toEqual(1)

      it "for moderator", ->
        renderSingleThreadWithProps({user_id: @moderatorId})
        expect($(".forum-nav-thread-label-staff").length).toEqual(1)

      it "for administrator", ->
        renderSingleThreadWithProps({user_id: @administratorId})
        expect($(".forum-nav-thread-label-staff").length).toEqual(1)

      it "for community TA", ->
        renderSingleThreadWithProps({user_id: @communityTaId})
        expect($(".forum-nav-thread-label-community-ta").length).toEqual(1)

      it "when none should be present", ->
        renderSingleThreadWithProps({})
        expect($(".forum-nav-thread-labels").length).toEqual(0)

    describe "browse menu", ->
      setupAjax = (callback) ->
        $.ajax.andCallFake(
          (params) =>
            if callback
              callback(params)
            params.success({discussion_data: [], page: 1, num_pages: 1})
            {always: ->}
        )

      afterEach ->
        # Remove handler added to make browse menu disappear
        $("body").unbind("click")

      expectBrowseMenuVisible = (isVisible) ->
        expect($(".forum-nav-browse-menu:visible").length).toEqual(if isVisible then 1 else 0)
        expect($(".forum-nav-thread-list-wrapper:visible").length).toEqual(if isVisible then 0 else 1)

      it "should not be visible by default", ->
        expectBrowseMenuVisible(false)

      it "should show when header button is clicked", ->
        $(".forum-nav-browse").click()
        expectBrowseMenuVisible(true)

      describe "when shown", ->
        beforeEach ->
          $(".forum-nav-browse").click()

        it "should hide when header button is clicked", ->
          $(".forum-nav-browse").click()
          expectBrowseMenuVisible(false)

        it "should hide when a click outside the menu occurs", ->
          $(".forum-nav-search-input").click()
          expectBrowseMenuVisible(false)

        it "should hide when a search is executed", ->
          setupAjax()
          $(".forum-nav-search-input").trigger($.Event("keydown", {which: 13}))
          expectBrowseMenuVisible(false)

        it "should hide when a category is clicked", ->
          $(".forum-nav-browse-title")[0].click()
          expectBrowseMenuVisible(false)

        it "should still be shown when filter input is clicked", ->
          $(".forum-nav-browse-filter-input").click()
          expectBrowseMenuVisible(true)

        describe "filtering", ->
          checkFilter = (filterText, expectedItems) ->
            $(".forum-nav-browse-filter-input").val(filterText).keyup()
            visibleItems = $(".forum-nav-browse-title:visible").map(
              (i, elem) -> $(elem).text()
            ).get()
            expect(visibleItems).toEqual(expectedItems)

          it "should be case-insensitive", ->
            checkFilter("flagged", ["Flagged Discussions"])

          it "should match partial words", ->
            checkFilter("ateg", ["Other Category"])

          it "should show ancestors and descendants of matches", ->
            checkFilter("Target", ["Parent", "Target", "Child"])

          it "should handle multiple words regardless of order", ->
            checkFilter("Following Posts", ["Posts I'm Following"])

          it "should handle multiple words in different depths", ->
            checkFilter("Parent Child", ["Parent", "Target", "Child"])

      describe "selecting an item", ->
        it "should clear the search box", ->
          setupAjax()
          $(".forum-nav-search-input").val("foobar")
          $(".forum-nav-browse-menu-following .forum-nav-browse-title").click()
          expect($(".forum-nav-search-input").val()).toEqual("")

        it "should change the button text", ->
          setupAjax()
          $(".forum-nav-browse-menu-following .forum-nav-browse-title").click()
          expect($(".forum-nav-browse-current").text()).toEqual("Posts I'm Following")

        testSelectionRequest = (callback, itemText) ->
          setupAjax(callback)
          $(".forum-nav-browse-title:contains(#{itemText})").click()

        it "should get all discussions", ->
          testSelectionRequest(
            (params) -> expect(params.url.path()).toEqual(DiscussionUtil.urlFor("threads")),
            "All"
          )

        it "should get flagged threads", ->
          testSelectionRequest(
            (params) ->
              expect(params.url.path()).toEqual(DiscussionUtil.urlFor("search"))
              expect(params.data.flagged).toEqual(true)
            ,
            "Flagged"
          )

        it "should get followed threads", ->
          testSelectionRequest(
            (params) ->
              expect(params.url.path()).toEqual(
                DiscussionUtil.urlFor("followed_threads", window.user.id)
              )
            ,
            "Following"
          )

        it "should get threads for the selected leaf", ->
          testSelectionRequest(
            (params) ->
              expect(params.url.path()).toEqual(DiscussionUtil.urlFor("search"))
              expect(params.data.commentable_ids).toEqual("child")
            ,
            "Child"
          )

        it "should get threads for children of the selected intermediate node", ->
          testSelectionRequest(
            (params) ->
              expect(params.url.path()).toEqual(DiscussionUtil.urlFor("search"))
              expect(params.data.commentable_ids).toEqual("child,sibling")
            ,
            "Parent"
          )
