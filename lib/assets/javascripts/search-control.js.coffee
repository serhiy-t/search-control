(($) ->
    INPUT_SELECTOR = '.search-control-input'
    RESULTS_SELECTOR = '.search-control-results'

    timestamp = () ->
        new Date().getTime()

    visibleResults = (new_value) ->
        results = $(RESULTS_SELECTOR)
        if new_value == true
            results.show()
        else if new_value == false
            results.hide()
        results.is(':visible')

    focusInput = () ->
        $(INPUT_SELECTOR).focus()

    searchEngines = () ->
        [
            {
                asyncQuery: (query, callback) ->
                    callback([
                            {
                                id: 1,
                                priority: 0,
                                render: () -> query
                            }
                        ])
            },
            {
                asyncQuery: (query, callback) ->
                    setTimeout (() ->
                        callback([
                                {
                                    id: 2,
                                    priority: 0,
                                    render: () -> 'hw'
                                }
                        ])),
                        1000
            }
        ]

    setQueriesStatus = (results) ->
        if results.data('queries') < 1
            results.removeClass('loading')
        else
            results.addClass('loading')

    showResults = (resultsPane, results) ->
        resultsPane.data('queries', resultsPane.data('queries') - 1)
        setQueriesStatus resultsPane

        if results == null
            return

        allResults = resultsPane.data('results')
        oldIds = {}; (oldIds[x.id] = x) for x in allResults
        (allResults.push x) for x in results when x.id not of oldIds

        allResults.sort (a, b) -> (a.priority - b.priority)

        resultsPane.data('results', allResults)

        resultsPane.empty()
        resultsPane.append(x.render x) for x in allResults

    initResultsForQuery = (results, queryId, enginesCount) ->
        results.data('queryId', queryId)
        results.data('results', [])
        results.data('queries', enginesCount)
        setQueriesStatus results

    performAsyncQuery = (query, results) ->
        engines = searchEngines()
        queryId = 'query_' + timestamp()

        initResultsForQuery results, queryId, engines.length

        $.each engines, (i, engine) ->
            engine.asyncQuery query, (result) ->
                if results.data('queryId') == queryId
                    showResults results, result

    runQuery = (query) ->
        if query.length == 0
            visibleResults false
        else
            visibleResults true
            results = $(RESULTS_SELECTOR)
            performAsyncQuery query, results

    buildQuery = (value) ->
        x for x in value.split(' ') when x.length > 0

    whenInputChanged = (value) ->
        runQuery (buildQuery value)

    $.search_control = (options) ->
        $(document).on('input', INPUT_SELECTOR, (event) ->
            whenInputChanged $(this).val())

        whenInputChanged $(INPUT_SELECTOR).val()

        focusInput()
        $(document).keydown((event) ->
            if event.keyCode == 27
                focusInput())
)(jQuery);
