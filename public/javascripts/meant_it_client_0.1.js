    // Variables/Constants from lib/constants, etc.
    var MESSAGE_TYPE_INPUT = "message_type_input";
    var PII_VALUE_INPUT = "pii_value_input";
    var MEANT_IT_REL_PAGE_SIZE = "pg_size";
    var MEANT_IT_REL_LAST_ID = "last_id";
    var MEANT_IT_REL_START_ID = "start_id";

    // Configurable variables
    var TIMEOUT = 50000;
    var POLL_INTERVAL = 10000;
    var BACKOFF = 3;

    // Set defaults if matches given value
    // E.g., if null then set to ""
    // This is important because javascript concatenates null
    // as 'null' instead of just nothing
    function setDefault(value, match_value, default_value)
    {
      var return_value;
      if (value == match_value)
      { 
        return_value = default_value;
      }
      else
      {
        return_value = value;
      } // end if (value == match_value)
      return return_value;
    } // end function setDefault(value, match_value, default_value)

    // Prepare key=value url pairs.
    // This convenience method just returns
    function setUrlParm(key, value)
    {
      return_str = "";
      if (value != null)
      {
        return_str = key+"="+value;
      } // end if (value != null)
      return return_str;
    } // end function setUrlParm(key, value)

    // Wrap obj around <a> tags
    // Params:
    // - obj_id: The html obj we want to wrap <a> around
    // - url: The url attached to the href of the <a> tags
    // Returns:
    // - null
    function makeClickable(obj_id, url) {
      var obj = jQuery("#"+obj_id);
      var inner_text = obj.text();
      var wrapped_inner_text = "<a href='"+url+"' >"+inner_text+"</a>";
      obj.html(wrapped_inner_text);
    } // end function makeClickable

    // Set a html object to be hidden or visible
    // Params:
    // - obj_id: The html obj we want to make visible or hide
    // - visibility: 'hidden', 'visible'
    // Returns:
    // - null
    function setVisibility(obj_id, visibility) {
      jQuery("#"+obj_id).css('visibility', visibility);
    } // end function setVisible

    // Add <li> elements to <ul>
    // Params:
    // - list_id: The id of the <ul> object that we want to add the list to
    // - mir_id: Unique id of the 
    // - src: Source of meant_it_rel
    // Returns:
    // - null
    function addToList(list_id, mir_id, src, message_type, dst, message) {
      var list_ul = jQuery('#'+list_id);
      var str = "("+mir_id+")"+" "+src+" <b>"+message_type+"</b> "+dst;
//DEBUG      var str = src+" "+message_type+" "+dst;
      if (message != null)
      {
        str += " <i>saying</i> '<b>"+message+"</i>'";
      } // end if (message != null)
      list_ul.append("<li>"+str+"</li>");
    } // end function addToList

    // Execute a function when we get list of meant_it_rels from server
    // asynchronously.
    // Params:
    // - func1: function to execute when ajax calls return with meant_it_rels
    // - pii_value: value of pii
    // - message_type: type of message
    // - timeout: how long to wait for conn (ms)
    // - poll_interval: how long to wait before retry (ms)
    // - backoff: this can be increased to increase retry
    // Returns:
    // - nil
    // IMPT: We don't return the results because when the function
    // finishes, asynchronous ajax call may not be done yet so nothing to
    // return.  Instead accept a function and execute the function
    // when ajax call returns
    function getJsonForMirs(func1, pii_value, message_type, page_size, start_id, last_id, timeout, poll_interval, backoff)
    {
      if (timeout == null)
      {
        timeout = TIMEOUT;
      } // end if (timeout == null)
      if (poll_interval == null)
      {
        poll_interval = POLL_INTERVAL;
      } // end if (poll_interval == null)
      if (backoff == null)
      {
        backoff = BACKOFF;
      } // end if (backoff == null)
      var normalized_start_id = setDefault(start_id, null, '');
      var normalized_last_id = setDefault(last_id, null, '');
      var normalized_page_size = setDefault(page_size, null, '');
      var return_obj; 
      jQuery.ajax({
          type: "GET",
          url: "/meant_it_rels/show_in_by_pii.json?"+MESSAGE_TYPE_INPUT+"="+message_type+"&"+PII_VALUE_INPUT+"="+pii_value+"&"+MEANT_IT_REL_PAGE_SIZE+"="+normalized_page_size+"&"+MEANT_IT_REL_START_ID+"="+normalized_start_id+"&"+MEANT_IT_REL_LAST_ID+"="+normalized_last_id,
          async: true, /* If set to non-async, browser shows page as "Loading.."*/
          cache: false,
          timeout: timeout, /* Timeout in ms */

          success: function(data)
          {
//DEBUG            alert("data:"+data);
            func1(data);
          },
          error: function(XMLHttpRequest, textStatus, errorThrown)
          {
            alert("error", textStatus + " (" + errorThrown + ")");
            setTimeout(
                function() {
                  'getJsonForMirs(pii_value, message_type, page_size, start_id, last_id, timeout, poll_interval, backoff)';
                }, /* Try again after.. */
                poll_interval*backoff); /* milliseconds */
          },
      });
    } // end function getJsonForMirs

    // Show the contents of Array containing meant_it_rels
    // Params:
    // - mir_arr: Array containing meant_it_rel
    // - list_id: The id of html object we will display the array.  This should be a <ul> element
    // - up_arrow_id: The id of html object containing up-arrow, so we trigger its visiblity if there are more pages up.  If null, then no pagination
    // - down_arrow_id: The id of html object containing up-arrow, so we trigger its visiblity if there are more pages down.  If null, then no pagination
    // Return:
    // null
    function showMirs(mirs, list_id, up_arrow_id, down_arrow_id)
    {
      var up_url_parms;
      var down_url_parms;
      jQuery.each(mirs, function(key, val)
        {
//DEBUG          alert("key:"+key+", val:"+val);
//DEBUG          alert("val.meant_it_rel.id:"+val.meant_it_rel.id);
          addToList(list_id, val.meant_it_rel.id, val.meant_it_rel.src_endpoint_id, val.meant_it_rel.message_type, PII_VALUE, val.meant_it_rel.message);
//MOVED_OUTSIDE          up_url_parms = val.meant_it_rel.up_url_parms;
//MOVED_OUTSIDE          down_url_parms = val.meant_it_rel.down_url_parms;
// DEBUG alert('up_url_parms:'+up_url_parms);
// DEBUG alert('down_url_parms:'+down_url_parms);
        }
      );
//MOVED_OUTSIDE      addPagination(up_arrow_id, down_arrow_id, up_url_parms, down_url_parms);
    } // end function showMirs

    function addPagination(base_url, up_arrow_id, down_arrow_id, up_url_parms, down_url_parms)
    {
      if (up_arrow_id != null && up_url_parms != null)
      {
         var up_url = base_url+"&"+up_url_parms;
//DEBUG    alert('up_url:'+up_url);
        setVisibility(up_arrow_id, "visible");
        makeClickable(up_arrow_id, up_url);
      } // end if (up_arrow_id != null && up_url_parms != null)
      if (down_arrow_id != null && down_url_parms != null)
      {
        var down_url = base_url+"&"+down_url_parms;
//DEBUG     alert('down_url:'+down_url);
        setVisibility(down_arrow_id, "visible");
        makeClickable(down_arrow_id, down_url);
      } // end if (down_url_parms != null)
    } // end function addPagination
