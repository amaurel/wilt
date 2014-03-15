/*
 * Packge : Wilt
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/06/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * Browser(dart:html) CouchDB HTTP adapter for Wilt.
 *  
 * This always returns a JSON Object the format of which is documented in
 * the Result Interface document
 *                      
 */

part of wiltBrowserClient;

class WiltBrowserHTTPAdapter implements WiltHTTPAdapter {

  /**
   *  Construction
   */
  WiltBrowserHTTPAdapter();

  /**
   * Processes the HTTP request, returning the server's response
   * as a future
   */
  Future<jsonobject.JsonObject> httpRequest(String method, String url, [String
      data = null, Map headers = null]) {


    /**
     *  Initialise 
     */
    Completer completer = new Completer();


    /**
     * Successful completion
     */
    void onSuccess(html.HttpRequest response) {

      /**
       *  Process the success response, note that an error response from CouchDB is 
       *  treated as an error, not as a success with an 'error' field in it.
       */
      jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
      jsonResponse.error = false;
      jsonResponse.errorCode = 0;
      jsonResponse.successText = null;
      jsonResponse.errorText = null;
      jsonResponse.allResponseHeader = null;
      jsonResponse.method = method;
      jsonResponse.responseText = response.responseText;

      /**
       * Check the header, if application/json try and decode it,
       * otherwise its just raw data, ie an attachment.
       */
      if (response.responseHeaders.containsValue('application/json')) {

        var couchResp;
        try {

          couchResp = JSON.decode(response.responseText);

        } catch (e) {

          jsonResponse.error = true;
          jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
          errorAsJson.error = "JSON Decode Error";
          errorAsJson.reason = "None";
          jsonResponse.jsonCouchResponse = errorAsJson;
          /* Set the response headers */
          jsonResponse.allResponseHeaders = response.getAllResponseHeaders();
          /**
            * Complete the reequest
            */
          if (!completer.isCompleted) completer.complete(jsonResponse);

        }

        if ((couchResp is Map) && (couchResp.containsKey('error'))) {

          jsonResponse.error = true;
          jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
          errorAsJson.error = "CouchDb Error";
          errorAsJson.reason = couchResp['reason'];
          jsonResponse.jsonCouchResponse = errorAsJson;
          /* Set the response headers */
          jsonResponse.allResponseHeaders = response.getAllResponseHeaders();
          /**
           * Complete the reequest
           */
          if (!completer.isCompleted) completer.complete(jsonResponse);

        }

        /**
         * Success response
         */
        if (method != Wilt.HEAD) {
          jsonobject.JsonObject successAsJson =
              new jsonobject.JsonObject.fromJsonString(response.responseText);
          jsonResponse.jsonCouchResponse = successAsJson;
        }


      } else {

        jsonobject.JsonObject successAsJson = new jsonobject.JsonObject();
        successAsJson.ok = true;
        successAsJson.contentType = response.responseHeaders['content-type'];
        jsonResponse.jsonCouchResponse = successAsJson;

      }


      /* Set the response headers */
      jsonResponse.allResponseHeaders = response.getAllResponseHeaders();
      /**
       * Complete the request
       */
      if (!completer.isCompleted) completer.complete(jsonResponse);


    }

    /**
     * Error completion
     */
    void onError(html.ProgressEvent response) {

      /* Get the HTTP request from the progress event */
      html.HttpRequest req = response.target;

      /* Process the error response */
      jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
      jsonResponse.method = method;
      jsonResponse.error = true;
      jsonResponse.successText = null;
      jsonResponse.responseText = req.responseText;
      jsonResponse.errorCode = req.status;
      if ((req.status != 0) && (method != Wilt.HEAD)) {
        jsonobject.JsonObject errorAsJson =
            new jsonobject.JsonObject.fromJsonString(req.responseText);
        jsonResponse.jsonCouchResponse = errorAsJson;
      } else {
        jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
        errorAsJson.error = "Invalid HTTP response";
        errorAsJson.reason = "HEAD or status code of 0";
        jsonResponse.jsonCouchResponse = errorAsJson;
      }

      /* Set the response headers */
      jsonResponse.allResponseHeaders = req.getAllResponseHeaders();

      /**
       * Complete the reequest
       */
      //if (!completer.isCompleted) completer.complete(jsonResponse);
      completer.completeError(new WiltException("",jsonResponse));

    }

    /**
     * Condition the input method string to get the HTTP method
     */
    List temp = method.split('_');
    String httpMethod = temp[0];
    
    /**
     *  Query CouchDB over HTTP 
     */
    html.HttpRequest.request(url, method: httpMethod, withCredentials: false,
        responseType: null, requestHeaders: headers, sendData: data)
        ..then(onSuccess,onError:onError);
        //..catchError(onError); make test case fail

    return completer.future;

  }
  
  /**
    *  Specialised get for change notifications
    */
  Future<String>getString(String url) {
    
     return html.HttpRequest.getString(url);
     
  }


}
