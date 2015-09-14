
/*
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
 */
(function($, _) {
  var TypeHelper, defaultOpt;
  defaultOpt = {
    initData: [],
    remoteData: [],
    tpl: "<li data-id='<%= id %>' ><a data-role='typeHelper' href='javascript:;'> <%= name %> </a></li>",
    maxNum: 6,
    confirmKeys: [13, 44, 32],
    emptyTip: '',
    emptyFunc: function() {},
    afterAdd: function() {},
    beforeAdd: function() {}
  };
  TypeHelper = function(element, opt) {
    _.each(defaultOpt, function(d, k) {
      return opt[k] = opt[k] || d;
    });
    this.opt = opt;
    this.maxNum = opt.maxNum;
    this.items = [];
    this.result = [];
    this.query = '';
    this.$element = $(element);
    this.$element.attr("type", "hidden");
    if (element.hasAttribute('placeholder')) {
      this.placeholderText = this.$element.attr('placeholder');
    } else {
      this.placeholderText = '';
    }
    this.$container = $('<div class="sf-typeHelper"></div>');
    this.$input = $('<input type="text" data-role="sf_typeHelper-input" class="sf-typeHelper-input" placeholder="' + this.placeholderText + '"/>').appendTo(this.$container);
    this.$list = $('<ul class="sf-typeHelper-list dropdown-menu"></ul>');
    this.$element.after(this.$container);
    this.$container.append(this.$list);
    return this.build(opt);
  };
  TypeHelper.prototype = {
    constructor: TypeHelper,
    getRemoteData: function(query, cb) {
      var filterData, self;
      self = this;
      filterData = [];
      if (typeof self.opt.remoteData === "object") {
        filterData = _.filter(self.opt.remoteData, function(d) {
          return d.name.search(query) !== -1;
        });
        if (cb) {
          return cb(filterData);
        }
      } else {
        if (self.timer) {
          clearTimeout(self.timer);
        }
        return self.timer = setTimeout(function() {
          return $.ajax({
            url: self.opt.remoteData,
            data: {
              q: query
            },
            dataType: "json",
            success: function(d) {
              filterData = d.data;
              filterData = _.map(filterData, function(d, k) {
                d.id = d.id || k;
                return d;
              });
              if (cb) {
                return cb(filterData);
              }
            }
          });
        }, 300);
      }
    },
    renderList: function(query) {
      var filterList, self;
      self = this;
      if (query.length > 0) {
        return self.getRemoteData(query, function(filterData) {
          var filterList;
          filterData = filterData;
          filterData = _.difference(filterData, self.result);
          if (filterData.length === 0 && self.opt.emptyTip.length > 0) {
            filterData.push({
              id: -1,
              name: self.opt.emptyTip
            });
          }
          self.items = filterData;
          filterList = _.reduce(filterData, function(mome, f) {
            return mome + _.template(self.opt.tpl)(f);
          }, '');
          if (filterList.length > 0) {
            self.$list.show();
          } else {
            self.$list.hide();
          }
          self.$list.html(filterList);
          return self.$list.find("li:first").addClass("active");
        });
      } else {
        filterList = '';
        self.$list.hide();
        return self.$list.html(filterList);
      }
    },
    renderInput: function() {
      var html, itemClass, self, tpl;
      self = this;
      self.$container.find(".sf-typeHelper-item").remove();
      self.$container.find(".sf-typeHelper-item-single").remove();
      itemClass = '';
      if (self.maxNum === 1) {
        itemClass = "-single";
      }
      html = '';
      tpl = '<span class="sf-typeHelper-item' + itemClass + '"> <%= name %> <span class="fa fa-times" data-role="remove"></span></span>';
      _.each(self.result, function(i) {
        var renderHtml;
        renderHtml = _.template(tpl)(i);
        return html += renderHtml;
      });
      self.$container.prepend(html);
      if (self.result.length === self.maxNum) {
        self.$input.attr("placeholder", '');
      } else {
        return self.$input.attr("placeholder", this.placeholderText);
      }
    },
    add: function(item) {
      var self;
      self = this;
      self.$list.trigger("hide");
      self.result.push(item);
      self.renderInput();
      if (self.opt.afterAdd) {
        return self.opt.afterAdd(self);
      }
    },
    remove: function(item) {
      var self;
      self = this;
      self.result = _.filter(self.result, function(d) {
        return d.name !== item.name;
      });
      return self.renderInput();
    },
    init: function(opt) {
      var self;
      self = this;
      self.result = opt.initData;
      return self.renderInput();
    },
    build: function(opt) {
      var self;
      self = this;
      if (opt.initData.length > 0) {
        self.init(opt);
      }
      self.$container.on('click', function() {
        self.$container.trigger('focus');
        return self.$input.trigger('focus');
      });
      self.$list.on('hide', function() {
        self.$input.val('');
        self.renderList('');
        return self.query = '';
      });
      self.$input.on('keydown', function(e) {
        var keyCode;
        keyCode = e.keyCode;
        if (keyCode === 8 && self.query.length === 0) {
          self.result.pop();
          return self.renderInput();
        }
      });
      self.$input.on('keypress', function(e) {
        var keyCode;
        keyCode = e.keyCode;
        if (self.result.length === self.maxNum) {
          return e.preventDefault();
        }
      });
      self.$input.on('keyup', function(e) {
        var _activeLi, currentIndex, keyCode, selectedItem;
        if (self.result.length === self.maxNum) {
          return;
        }
        self.query = $(this).val();
        keyCode = e.keyCode;
        switch (keyCode) {
          case 8:
            return self.renderList(self.query);
          case 13:
            currentIndex = self.$list.find("li.active").index();
            selectedItem = self.items[currentIndex];
            if (selectedItem.id !== -1 && !(_.find(self.result, function(r) {
              return r.id === selectedItem.id;
            }))) {
              self.add(selectedItem);
            } else {
              if (self.opt.emptyFunc) {
                self.opt.emptyFunc();
              }
            }
            return self.$list.trigger("hide");
          case 38:
            _activeLi = self.$list.find("li.active");
            currentIndex = _activeLi.index();
            if (currentIndex > 0) {
              _activeLi.removeClass("active");
              return _activeLi.prev("li").addClass("active");
            }
            break;
          case 40:
            _activeLi = self.$list.find("li.active");
            currentIndex = _activeLi.index();
            if (currentIndex < self.items.length - 1) {
              _activeLi.removeClass("active");
              return _activeLi.next("li").addClass("active");
            }
            break;
          default:
            return self.renderList(self.query);
        }
      });
      $("body").on('click', function(e) {
        var $target, role;
        $target = $(e.target);
        role = $target.attr("data-role");
        if (role === "typeHelper") {

        } else {
          return self.$list.trigger("hide");
        }
      });
      self.$container.on('click', '[data-role=remove]', function() {
        var $element, $item, item, key;
        $element = $(this);
        $item = $element.closest(".sf-typeHelper-item");
        key = $item.index();
        item = self.result[key];
        return self.remove(item);
      });
      self.$list.on('click', 'li', function() {
        var key, selectedItem;
        key = $(this).index();
        selectedItem = self.items[key];
        if (selectedItem.id !== -1 && !(_.find(self.result, function(r) {
          return r.id === selectedItem.id;
        }))) {
          self.add(selectedItem);
        } else {
          if (self.opt.emptyFunc) {
            self.opt.emptyFunc();
          }
        }
        return self.$list.trigger("hide");
      });
      return self;
    }
  };
  $.fn.typeHelper = function(opt) {
    return new TypeHelper($(this)[0], opt);
  };
  return $.fn.typeHelper.Constructor = TypeHelper;
})($, _);
