// this is patch for js function from core
function addFilter(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var tr = $('#tr_'+fieldId);
  if (tr.length > 0) {
    tr.show();
  } else {
    // ========= patch start ============
    if (field == 'issue_version_filter') {
      buildFilterRowIssueVersionPatch(field, operator, values);
    } else if(field == 'from_versions_open_version_filter'){
      buildFilterRowFromVersionPatch(field, operator, values);
    } else {
      buildFilterRow(field, operator, values);
    }
    // ========= patch end ============
  }
  $('#cb_'+fieldId).attr('checked', true);
  toggleFilter(field);
  $('#add_filter_select').val('').children('option').each(function(){
    if ($(this).attr('value') == field) {
      $(this).attr('disabled', true);
    }
  });
}

function buildFilterRowIssueVersionPatch(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var filterTable = $("#filters-table");
  var filterOptions = availableFilters[field];
  if (!filterOptions) return;
  var operators = operatorByType['float'].slice(0, 3);
  var filterValues = filterOptions['values'];
  var i, select;
  // check if custom filter was chosen
  var tr = $('<tr class="filter">').attr('id', 'tr_'+fieldId).html(
    '<td class="field"><input checked="checked" id="cb_'+fieldId+'" name="f[]" value="'+field+'" type="checkbox"><label for="cb_'+fieldId+'"> '+filterOptions['name']+'</label></td>' +
    '<td class="operator"><select id="operators_'+fieldId+'" name="op['+field+']"></td>' +
    '<td class="values"></td>'
  );

  filterTable.append(tr);

  select = tr.find('td.operator select');

  // dropdown list of operators

  for (i=0;i<operators.length;i++){
    var option = $('<option>').val(operators[i]).text(operators[i]);
    if (operators[i] == operator) { option.attr('selected', true); }
    select.append(option);
  }
  select.change(function(){ toggleOperator(field); });

  // input field for version

  tr.find('td.values').append(
    '<span style="display:none;"><select class="value" id="values_'+fieldId+'_1" name="v['+field+'][]"></select>'
  );

  select = tr.find('td.values select');
  for (i=0;i<filterValues.length;i++){
    var filterValue = filterValues[i];
    var option = $('<option>');
    option.val(filterValue).text(filterValue);
    if (filterValues[i] == values[0]){
      option.attr('selected', true);
    }
    select.append(option);
  }

}

function buildFilterRowFromVersionPatch(field, operator, values) {
  var fieldId = field.replace('.', '_');
  var filterTable = $("#filters-table");
  var filterOptions = availableFilters[field];
  var filterValues = filterOptions['values'];
  var i, select;
  
  // filter from open version was chose
  var tr = $('<tr class="filter">').attr('id', 'tr_'+fieldId).html(
    '<td class="field"><input checked="checked" id="cb_'+fieldId+'" name="f[]" value="'+field+'" type="checkbox"><label for="cb_'+fieldId+'"> '+filterOptions['name']+'</label></td>' + '<td class="values"></td>'
  );
  
  filterTable.append(tr);

  tr.find('td.values').append(
    '<span style="display:none;"><select class="value" id="values_'+fieldId+'_1" name="v['+field+'][]"></select>'
  );

  select = tr.find('td.values select');
  for (i=0;i<filterValues.length;i++){
    var filterValue = filterValues[i];
    var option = $('<option>');
    if ($.isArray(filterValue)) {
      option.val(filterValue[1]).text(filterValue[0]);
      if ($.inArray(filterValue[1], values) > -1) {option.attr('selected', true);}
    } else {
      option.val(filterValue).text(filterValue);
      if ($.inArray(filterValue, values) > -1) {option.attr('selected', true);}
    }
    select.append(option);
  }

}