# sf typeHelper 扩展器

# 技术标签 techTag

define ->
    typeHelperExtend = {
        realm: (typeHelper) ->
            _typeHelperInput = typeHelper.$input
            _realmPanel = $("#realmTags")
            _close = _realmPanel.find(".js-close")
            _checkBox = $('#realmTags input[type=checkbox]')

            # 判断是否已达到最大可输入数量
            maxTest = ()->
                if typeHelper.result.length is typeHelper.opt.maxNum
                    _checkBox.not(":checked").attr "disabled", "disabled"
                else
                    _checkBox.not(":checked").removeAttr "disabled"
            maxTest()

            _typeHelperInput.on("focus", ()->
                _realmPanel.show()
            )
            _close.on("click", ()->
                _realmPanel.hide()
            )

            typeHelper.opt.afterAdd = (item)->
                $("input[data-id=" + item.id + "]").prop("checked", true)
                maxTest()

            typeHelper.opt.afterRemove = (item)->
                $("input[data-id=" + item.id + "]").prop("checked", false)
                maxTest()


            _checkBox.change () ->
                tagId = $(this).data('id')
                tagName = $(this).val()
                item = {
                    name: tagName
                    id: tagId
                }
                if $(this).prop('checked')
                    typeHelper.add(item)
                else
                    typeHelper.remove(item)
                maxTest()




        techTag: (typeHelper)->
            _techTag = $('#techTags')
            _techTagClose = $('#techTags .close')
            _checkBox = $('#techTags input[type=checkbox]')

            # 判断是否已达到最大可输入数量
            maxTest = ()->
                if typeHelper.result.length is typeHelper.opt.maxNum
                    _checkBox.not(":checked").attr "disabled", "disabled"
                else
                    _checkBox.not(":checked").removeAttr "disabled"
            maxTest()

            $(".sf-typeHelper-input").on("focus", ()->
                _techTag.show()
            )

            _techTagClose.click ()->
                _techTag.hide()

            typeHelper.opt.afterAdd = (item)->
                $("input[data-id=" + item.id + "]").prop("checked", true)
                maxTest()

            typeHelper.opt.afterRemove = (item)->
                $("input[data-id=" + item.id + "]").prop("checked", false)
                maxTest()


            _checkBox.change () ->
                tagId = $(this).data('id')
                tagName = $(this).val()
                item = {
                    name: tagName
                    id: tagId
                }
                if $(this).prop('checked')
                    typeHelper.add(item)
                else
                    typeHelper.remove(item)
                maxTest()
    }
    return typeHelperExtend