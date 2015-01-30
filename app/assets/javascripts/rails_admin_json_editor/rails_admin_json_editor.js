//= require rails_admin_json_editor/vue.0.11.4
//= require rails_admin_json_editor/lodash.2.4.1
//= require rails_admin_json_editor/markdown

var vm;

$(document).on('rails_admin.dom_ready', function() {
  // TODO: Make this possible for multiple instances

  // Get data
  var jsonResult = $('[ref=json-editor]').data('json-result');
  var jsonScheme = $('[ref=json-editor]').data('json-scheme');

  if(!jsonResult) {
    jsonResult = { components: [] };
  }

  Vue.filter('markdown', function(value) {
    return markdown.toHTML(value);
  });

  // Setup templates for models
  var components = {};
  _.each(jsonScheme.models, function(model) {
    components['fields-for-' + model.name] = {
      template: '#template-fields-for-' + model.name,
      data: function() {
        return {
          expanded: true,
          showPreview: false
        };
      },
      computed: {
        moveUpEnabled: function() {
          return this.parentIndex > 0;
        },
        moveDownEnabled: function() {
          return this.parentIndex < this.parentComponents.length - 1;
        },
      },
      methods: {
        moveUp: function() {
          var from = this.parentIndex;
          var to = this.parentIndex - 1;
          var element = this.parentComponents[from];
          this.parentComponents.splice(from, 1);
          this.parentComponents.splice(to, 0, element);
        },

        moveDown: function() {
          var from = this.parentIndex;
          var to = this.parentIndex + 1;
          var element = this.parentComponents[from];
          this.parentComponents.splice(from, 1);
          this.parentComponents.splice(to, 0, element);
        },

        remove: function() {
          if(_.values(this.component.properties).length === 0 || confirm("Are you sure?")) {
            this.parentComponents.$remove(this.parentIndex);
          }
        },

        // TODO: DRY up with $root.addComponent
        addComponent: function(event, target, model) {
          event.preventDefault();

          var clonedproperties = _.clone(this.component.properties);
          if(!clonedproperties[target]) {
            clonedproperties[target] = [];
          }

          var obj = {
            model_name: model.name,
            properties: {}
          };

          clonedproperties[target].push(obj);
          this.parentComponents[this.parentIndex].properties = clonedproperties;
        },

        onChangePicker: function(event, fieldName) {
          var el = event.target;
          var value = el.options[el.selectedIndex].getAttribute('data-json');
          var json = JSON.parse(value);

          var clonedproperties = _.clone(this.component.properties);
          clonedproperties[fieldName] = json;
          this.parentComponents[this.parentIndex].properties = clonedproperties;
        },

        pickerOptionIsSelected: function(fieldName, recordLabel, recordName) {
          return this.component.properties &&
            this.component.properties[fieldName] &&
            this.component.properties[fieldName][recordLabel] &&
            this.component.properties[fieldName][recordLabel] === recordName;
        },

        nestedModelIsAllowed: function(model, allowedModels) {
          return _.contains(allowedModels, model.name);
        }
      }
    };
  });

  // Let's go
  vm = new Vue({
    el: '[ref=json-editor]',
    data: {
      components: jsonResult.components,
      scheme: jsonScheme,
      showJson: false
    },
    methods: {
      addComponent: function(e, model) {
        console.log('addComponent', model);
        e.preventDefault();

        var obj = {
          model_name: model.name,
          properties: {}
        };

        this.components.push(obj);
      }
    },
    computed: {
      result: function() {
        return { components: this.components };
      }
    },
    components: components
  });
});
