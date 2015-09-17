define(function() {
  var typeHelperExtend;
  typeHelperExtend = {
    realm: function(typeHelper) {
      var _checkBox, _close, _realmPanel, _typeHelperInput, maxTest;
      _typeHelperInput = typeHelper.$input;
      _realmPanel = $("#realmTags");
      _close = _realmPanel.find(".js-close");
      _checkBox = $('#realmTags input[type=checkbox]');
      maxTest = function() {
        if (typeHelper.result.length === typeHelper.opt.maxNum) {
          return _checkBox.not(":checked").attr("disabled", "disabled");
        } else {
          return _checkBox.not(":checked").removeAttr("disabled");
        }
      };
      maxTest();
      _typeHelperInput.on("focus", function() {
        return _realmPanel.show();
      });
      _close.on("click", function() {
        return _realmPanel.hide();
      });
      typeHelper.opt.afterAdd = function(item) {
        $("input[data-id=" + item.id + "]").prop("checked", true);
        return maxTest();
      };
      typeHelper.opt.afterRemove = function(item) {
        $("input[data-id=" + item.id + "]").prop("checked", false);
        return maxTest();
      };
      return _checkBox.change(function() {
        var item, tagId, tagName;
        tagId = $(this).data('id');
        tagName = $(this).val();
        item = {
          name: tagName,
          id: tagId
        };
        if ($(this).prop('checked')) {
          typeHelper.add(item);
        } else {
          typeHelper.remove(item);
        }
        return maxTest();
      });
    },
    techTag: function(typeHelper) {
      var _checkBox, _techTag, _techTagClose, maxTest;
      _techTag = $('#techTags');
      _techTagClose = $('#techTags .close');
      _checkBox = $('#techTags input[type=checkbox]');
      maxTest = function() {
        if (typeHelper.result.length === typeHelper.opt.maxNum) {
          return _checkBox.not(":checked").attr("disabled", "disabled");
        } else {
          return _checkBox.not(":checked").removeAttr("disabled");
        }
      };
      maxTest();
      $(".sf-typeHelper-input").on("focus", function() {
        return _techTag.show();
      });
      _techTagClose.click(function() {
        return _techTag.hide();
      });
      typeHelper.opt.afterAdd = function(item) {
        $("input[data-id=" + item.id + "]").prop("checked", true);
        return maxTest();
      };
      typeHelper.opt.afterRemove = function(item) {
        $("input[data-id=" + item.id + "]").prop("checked", false);
        return maxTest();
      };
      return _checkBox.change(function() {
        var item, tagId, tagName;
        tagId = $(this).data('id');
        tagName = $(this).val();
        item = {
          name: tagName,
          id: tagId
        };
        if ($(this).prop('checked')) {
          typeHelper.add(item);
        } else {
          typeHelper.remove(item);
        }
        return maxTest();
      });
    }
  };
  return typeHelperExtend;
});
