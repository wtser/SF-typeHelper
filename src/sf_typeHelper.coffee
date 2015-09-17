###
typeHelper = {
    name: '输入辅助器'
    desc: '标签输入组件,支持输入多个值'
    author: 'wtser@segmentfault.com'
    dep: 'jquery,underscore'

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

# 默认配置项
    defaultOpt = {
        initData: []
        remoteData: []
        inputTpl: '<span class="sf-typeHelper-item<%= itemClass %> "> <%= name %> <span class="fa fa-times" data-role="remove"></span></span>'
        tpl: "<li data-id='<%= id %>' ><a data-role='typeHelper' href='javascript:;'><% if (typeof(img)!='undefined'){ %> <img src='<%= img %>'> <% } %> <%= name %> </a></li>"
        maxNum: 5
        confirmKeys: [13, 44, 32]
        emptyTip: ''
        emptyFunc: ()-> return
        afterAdd: ()-> return
        afterRemove: ()-> return
        beforeAdd: ()-> return
    }


    TypeHelper = (element, opt)->
        if element.length is 0
            console.warn "element not found in DOM"
            return

        # opt 数据重载
        _.each defaultOpt, (d, k)->
            opt[k] = opt[k] ? d

        this.opt = opt

        # ajax search 请求到的数据 即 ul 下拉菜单渲染数据 items
        this.items = []

        # 用户选择得最终数据 result
        this.result = []

        # 用户键入的用于查询的字符串
        this.query = ''

        # 输入框元素 type hidden 改为class hidden 为了兼容form的报错功能
        this.$element = $(element)
        this.$element.addClass("hidden")

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
        formatter: (filterData)->
            filterData = filterData ? []
            data = _.map filterData, (d, k)->
                if typeof(d) isnt "object"
                    o = {}
                    o.name = d
                    o.id = k
                    d = o
                d.name = d.name ? d
                d.id = d.id ? k
                d.img = d.img ? d.avatarUrl
                return d
            return data
        getRemoteData: (query, cb)->
            self = this
            filterData = []
            if typeof self.opt.remoteData is "object"

                filterData = self.formatter(self.opt.remoteData)
                filterData = _.filter filterData, (d)-> return d.name.search(query) != -1
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
                                filterData = self.formatter(filterData)
                                if cb then cb(filterData)
                        }
                    )
                , 300


        renderList: (query)->
            self = this
            if query.length > 0
                self.getRemoteData(query, (filterData)->
                    filterData = _.difference filterData, self.result

                    if filterData.length is 0 and self.opt.emptyTip.length > 0
                        filterData.push {id: -1, name: self.opt.emptyTip}
                    self.items = filterData

                    filterList = _.reduce filterData, (memo, f)->
                        return memo + _.template(self.opt.tpl)(f)
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
            if self.opt.maxNum is 1
                itemClass = "-single"


            if self.opt.inputTpl.length > 0

                html = _.reduce self.result, (memo, i)->
                    i.itemClass = itemClass
                    return memo + _.template(self.opt.inputTpl)(i)
                , ""
                self.$container.prepend html

            if self.opt.maxNum isnt 0 and self.result.length is self.opt.maxNum
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

            if self.opt.afterAdd then self.opt.afterAdd(item, self)



        remove: (item)->
            self = this
            self.result = _.filter self.result, (d)-> return d.name != item.name
            self.renderInput()

            if self.opt.afterRemove then self.opt.afterRemove(item, self)


        init: (opt)->
            self = this
            self.result = self.formatter(opt.initData)
            self.renderInput()

        build: (opt)->
            self = this

            if self.placeholderText.length > 0
                self.$input.css("width", self.placeholderText.length + "em")


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
                    self.remove(_.last(self.result))
                    self.renderInput()

                # 回车 阻止可能的表单提交事件
                if keyCode is 13
                    e.preventDefault()

                # 数据达到最大可输入数量后阻止
                if  self.result.length is self.opt.maxNum and self.opt.maxNum isnt 0
                    e.preventDefault()
            )

            self.$input.on('keyup', (e)->
                if self.result.length is self.opt.maxNum and self.opt.maxNum isnt 0
                    return
                self.query = $(this).val()
                keyCode = e.keyCode


                switch keyCode

# 回退
                    when 8 then self.renderList(self.query)
# 回车
                    when 13
                        currentIndex = self.$list.find("li.active").index()
                        selectedItem = self.items[currentIndex]

                        if selectedItem.id != -1 and !( _.find self.result, (r)-> return r.id == selectedItem.id)
                            self.add selectedItem

                        else
                            if self.opt.emptyFunc then self.opt.emptyFunc()

                        self.$list.trigger("hide")
# 向上
                    when 38
                        _activeLi = self.$list.find("li.active")
                        currentIndex = _activeLi.index()
                        if currentIndex > 0
                            _activeLi.removeClass("active")
                            _activeLi.prev("li").addClass("active")

# 向下
                    when 40
                        _activeLi = self.$list.find("li.active")
                        currentIndex = _activeLi.index()
                        if currentIndex < self.items.length - 1
                            _activeLi.removeClass("active")
                            _activeLi.next("li").addClass("active")
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

            return


    }


    $.fn.typeHelper = (opt) ->
        new TypeHelper($(this)[0], opt)
