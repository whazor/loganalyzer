

$ ->
  stopDefaults = (e) ->
    #e = e.originalEvent
    e.stopPropagation()
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'


  #d3 settings
  settings =
    w: 940
    h: 940

  OPERATOR = ///
  (.*) \x20 # host
  (.*) \x20 # hyphen
  (.*) \x20 # user
  \[(.*)\] \x20 # time
  \"....? (\S*) .*\" \x20 # request
  (\d*) \x20 # status
  (\d*) # size
  # (.*) # overige troep
  #\x20 \"(.*)\" \x20 #referer
  #\"(.*)\" \"(.*)\" \"(.*)\" (.*) (.*) (.*)
  ///
  files = []
  handleFileSelect = (e) ->
    stopDefaults(e)
    files = e.dataTransfer.files

    renderFiles()

  $('.render').bind 'click', ->
    renderFiles()
    return false

  renderFiles = ->
    $('.files').html('')

    template = _.template $('#file').html()

    for f in files
      t = $(template {'name': escape(f.name) })
      $('.files').append t
      chart = t.children('.chart')[0]

      pack = d3.layout
        .pack()
        .size([settings.w - 4, settings.h - 4])
        .value((d) -> return d.size)

      vis = d3
        .select(chart)
        .append('svg')
        .attr('width', settings.w)
        .attr('height', settings.h)
        .attr('class', 'pack')
        .append('g')
        .attr('transform', 'translate(2, 2)')

      reader = new FileReader()
      reader.onload = ->
        arr = reader.result.split("\n")
        data =
          name: ""
          children: []

        
        if $('.search-query').val() != ''
          val = new RegExp($('.search-query').val())

          search = (url) -> val.test(url)
        else
          search = (url) -> true

        if $('.googlebot').is(':checked')
          google = (host) -> host.split("googlebot").length > 1
        else
          google = (host) -> true

        filter = (host, url, status) -> status == "200" and search(url) and google(host)

        for line in arr
          m = line.match(OPERATOR)
          continue if line == "" or !m or m.length < 6
          [host, url, status] = [m[1], m[5], m[6]]
          continue unless filter(host, url, status)
          paths = url.split('/')
          pointer = null
          # Ga elk pad af
          for path, i in paths
            # Root pad
            unless pointer
              pointer = data
            else
              continue if path == ""
              child = { name: path }
              # Als de pointer kinderen heeft
              if pointer.children
                result = _.find pointer.children, (e) -> e.name == path
                if result
                  result.size += 1 if result.size
                  child = result
                else
                  if (i+1) == paths.length
                    child.size = 1
                  else
                    child.children = []
                  pointer.children.push(child)

                #else if (i+1) == paths.length
                #pointer.data
              else
                delete pointer.size
                child = { name: path }
                if (i+1) == paths.length
                  child.size = 1
                else
                  child.children = []

                pointer.children = [child]
              pointer = child

        node = vis
          .data([data])
          .selectAll("g.node")
          .data(pack.nodes)
          .enter()
          .append("g")
          .attr("class", (d) -> d.children ? "node" : "leaf node")
          .attr("transform", (d) -> "translate(#{d.x}, #{d.y})")

        node.append("title")
          .text (d) -> d.name
        node.append("circle")
          .attr("r", (d) -> d.r)

        node.filter((d) -> !d.children).append("text")
          .attr("text-anchor", "middle")
          .attr("dy", 5)#(d) -> !d.children ? 10 : d.r - 10)
          .text (d) -> d.name.substring(0, d.r / 4)

      reader.readAsText(f)


  $('.dropbox')[0].addEventListener 'dragenter', stopDefaults, false
  $('.dropbox')[0].addEventListener 'dragover', stopDefaults, false
  $('.dropbox')[0].addEventListener 'drop', handleFileSelect, false

