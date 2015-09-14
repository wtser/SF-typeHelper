###
typeHelper = {
    name: '输入辅助器'
    desc: '标签输入组件,支持输入多个值'
    author: 'wtser@segmentfault.com'
    dep: 'jquery,undersocre'

    opt: {
        tpl: '模板 (可选)'
        remoteData: '输入过程返回的远程数据'
        initData: '初始化渲染数据'
        maxNum:'允许输入的内容最大数量值'
        emptyFunc:'匹配数据未空时,自行处理的回调函数'
        emptyTip:'匹配数据未空时,提示文字'
        afterAdd:'add 之后执行特定脚本'
    }
}
###

do ($, _)->
    defaultOpt = {
        initData: []
        remoteData: []
        tpl: "<li data-id='<%= id %>' ><a data-role='typeHelper' href='javascript:;'> <%= name %> </a></li>"
        maxNum: 6
        confirmKeys: [13, 44, 32]
        emptyTip: ''
        emptyFunc: ()-> return
        afterAdd: ()-> return
        beforeAdd: ()-> return
    }

    TypeHelper = (element, opt)->
# opt 数据初始化
        _.each defaultOpt, (d, k)->
            opt[k] = opt[k] || d


        this.opt = opt
        this.maxNum = opt.maxNum
        # ul 下拉菜单渲染数据 items
        this.items = []
        # 用户输入最终数据 result
        this.result = []
        this.query = ''

        this.$element = $(element)
        this.$element.attr("type", "hidden")

        if element.hasAttribute('placeholder')
            this.placeholderText = this.$element.attr('placeholder')
        else
            this.placeholderText = ''


        this.$container = $('<div class="sf-typeHelper"></div>');
        this.$input = $('<input type="text" data-role="sf_typeHelper-input" class="sf-typeHelper-input" placeholder="' + this.placeholderText + '"/>').appendTo(this.$container)
        this.$list = $('<ul class="sf-typeHelper-list dropdown-menu"></ul>')
        this.$element.after(this.$container)
        this.$container.append(this.$list)


        this.build(opt)


    TypeHelper.prototype = {
        constructor: TypeHelper,
        getRemoteData: (query, cb)->
            self = this
            filterData = []
            if typeof self.opt.remoteData is "object"
                filterData = _.filter self.opt.remoteData, (d)-> return d.name.search(query) != -1
                if cb then cb(filterData)
            else
                if self.timer
                    clearTimeout(self.timer)
                self.timer = setTimeout ()->
                    $.ajax({
                            url: self.opt.remoteData
                            data: {q: query}
                            dataType: "json"
                            success: (d)->
                                filterData = d.data
                                filterData = _.map filterData, (d, k)->
                                    d.id = d.id || k
                                    return d
                                if cb then cb(filterData)
                        }
                    )
                , 300


        renderList: (query)->
            self = this
            if query.length > 0
                self.getRemoteData(query, (filterData)->
                    filterData = filterData
                    filterData = _.difference filterData, self.result

                    if filterData.length is 0 and self.opt.emptyTip.length > 0
                        filterData.push {id: -1, name: self.opt.emptyTip}
                    self.items = filterData

                    filterList = _.reduce filterData, (mome, f)->
                        return mome + _.template(self.opt.tpl)(f)
                    , ''

                    if filterList.length > 0
                        self.$list.show()
                    else
                        self.$list.hide()
                    self.$list.html(filterList)
                    self.$list.find("li:first").addClass("active")
                )

            else
                filterList = ''
                self.$list.hide()
                self.$list.html(filterList)




        renderInput: ()->
            self = this
            self.$container.find(".sf-typeHelper-item").remove()
            self.$container.find(".sf-typeHelper-item-single").remove()

            itemClass = ''
            if self.maxNum is 1
                itemClass = "-single"

            html = ''
            tpl = '<span class="sf-typeHelper-item' + itemClass + '"> <%= name %> <span class="fa fa-times" data-role="remove"></span></span>'
            _.each self.result, (i)->
                renderHtml = _.template(tpl)(i)
                html += renderHtml
            self.$container.prepend html

            if self.result.length is self.maxNum
                self.$input.attr("placeholder", '')
                # self.$input.attr("readonly", true)
                return
            else
                self.$input.attr("placeholder", this.placeholderText)

        add: (item)->
            self = this

            self.$list.trigger("hide")

            self.result.push item
            self.renderInput()

            if self.opt.afterAdd then self.opt.afterAdd(self)



        remove: (item)->
            self = this
            self.result = _.filter self.result, (d)-> return d.name != item.name
            self.renderInput()


        init: (opt)->
            self = this
            self.result = opt.initData
            self.renderInput()

        build: (opt)->
            self = this


            if opt.initData.length > 0
                self.init(opt)

            self.$container.on('click', ()->
                self.$container.trigger('focus')
                self.$input.trigger('focus')
            )

            self.$list.on('hide', ()->
                self.$input.val('')
                self.renderList('')
                self.query = ''
            )


            self.$input.on('keydown', (e)->
                keyCode = e.keyCode

                if keyCode is 8 and self.query.length is 0
                    self.result.pop()
                    self.renderInput()


#console.log 'keydown' + keyCode
            )
            self.$input.on('keypress', (e)->
                keyCode = e.keyCode
                if self.result.length is self.maxNum
                    e.preventDefault()
            )

            self.$input.on('keyup', (e)->
                if self.result.length is self.maxNum
                    return
                self.query = $(this).val()
                keyCode = e.keyCode


                switch keyCode

                    when 8 then self.renderList(self.query) #回退
                    when 13 #回车
                        currentIndex = self.$list.find("li.active").index()
                        selectedItem = self.items[currentIndex]

                        if selectedItem.id != -1 and !( _.find self.result, (r)-> return r.id == selectedItem.id)
                            self.add selectedItem

                        else
                            if self.opt.emptyFunc then self.opt.emptyFunc()

                        self.$list.trigger("hide")
                    when 38 #向上
                        _activeLi = self.$list.find("li.active")
                        currentIndex = _activeLi.index()
                        if currentIndex > 0
                            _activeLi.removeClass("active")
                            _activeLi.prev("li").addClass("active")

                    when 40 #向下
                        _activeLi = self.$list.find("li.active")
                        currentIndex = _activeLi.index()
                        if currentIndex < self.items.length - 1
                            _activeLi.removeClass("active")
                            _activeLi.next("li").addClass("active")
# when 46 then console.log '删除'
# when 37 then console.log '左箭头'
# when 39 then console.log '右箭头'
                    else
                        self.renderList(self.query)
            )

            $("body").on('click', (e)->
                $target = $(e.target)
                role = $target.attr("data-role")
                if role is "typeHelper"
                    return
                else
                    self.$list.trigger("hide")
            )


            self.$container.on('click', '[data-role=remove]', ()->
                $element = $(this)
                $item = $element.closest(".sf-typeHelper-item")

                key = $item.index()
                item = self.result[key]
                self.remove(item)
            )

            self.$list.on('click', 'li', ()->
                key = $(this).index()
                selectedItem = self.items[key]
                if selectedItem.id != -1 and !( _.find self.result, (r)-> return r.id == selectedItem.id)
                    self.add selectedItem

                else
                    if self.opt.emptyFunc then self.opt.emptyFunc()
                self.$list.trigger("hide")
            )

            return self


    }


    $.fn.typeHelper = (opt) ->
        new TypeHelper($(this)[0], opt)


    $.fn.typeHelper.Constructor = TypeHelper;



