App.HomeView = Parse.View.extend
  className: 'row-fluid chart'

  template: $.template 'content-home'
  initialize: ->
  
  render: ->
    @$el.html @template {}
    showInstrumenttip = (x, y, contents) ->
      $("<div id=\"tooltip\">#{contents}</div>").css(
        position: "absolute"
        display: "none"
        top: y - 30
        left: x - 50
        color: "#fff"
        padding: "2px 5px"
        "border-radius": "6px"
        "background-color": "#000"
        opacity: 0.80
      ).appendTo("body").fadeIn 200
    visits = [[1, 50], [2, 40], [3, 45], [4, 23], [5, 55], [6, 65], [7, 61], [8, 70], [9, 65], [10, 75], [11, 57], [12, 59]]
    visitors = [[1, 25], [2, 50], [3, 23], [4, 48], [5, 38], [6, 40], [7, 47], [8, 55], [9, 43], [10, 50], [11, 47], [12, 39]]
    plot = $.plot($("#statsChart"), [
      data: visits
      label: "Signups"
    ,
      data: visitors
      label: "Visits"
    ],
      series:
        lines:
          show: true
          lineWidth: 1
          fill: true
          fillColor:
            colors: [
              opacity: 0.1
            ,
              opacity: 0.13
            ]

        points:
          show: true
          lineWidth: 2
          radius: 3

        shadowSize: 0
        stack: true

      grid:
        hoverable: true
        clickable: true
        tickColor: "#f9f9f9"
        borderWidth: 0

      legend:
        labelBoxBorderColor: "#fff"

      colors: ["#a7b5c5", "#30a0eb"]
      xaxis:
        ticks: [[1, "JAN"], [2, "FEB"], [3, "MAR"], [4, "APR"], [5, "MAY"], [6, "JUN"], [7, "JUL"], [8, "AUG"], [9, "SEP"], [10, "OCT"], [11, "NOV"], [12, "DEC"]]
        font:
          size: 12
          family: "Open Sans, Arial"
          variant: "small-caps"
          color: "#697695"

      yaxis:
        ticks: 3
        tickDecimals: 0
        font:
          size: 12
          color: "#9da3a9"
    )
    previousPoint = null
    $("#statsChart").bind "plothover", (event, pos, item) ->
      if item
        unless previousPoint is item.dataIndex
          previousPoint = item.dataIndex
          $("#tooltip").remove()
          x = item.datapoint[0].toFixed(0)
          y = item.datapoint[1].toFixed(0)
          month = item.series.xaxis.ticks[item.dataIndex].label
          showInstrumenttip item.pageX, item.pageY, item.series.label + " of " + month + ": " + y
      else
        $("#tooltip").remove()
        previousPoint = null
    
    @
  
  search: (event) ->
    term = event.target.value
    console.log @table
    @table.fnFilter term, null
    

App.StatsView = Parse.View.extend
  className: 'row-fluid stats-row'
  template: $.template 'content-stats'
  
  initialize: ->
    @render()
  
  render: ->
    @$el.html @template visits: 2457, users: 3, orders: 322, sales: 2340