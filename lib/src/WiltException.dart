/*
 * Packge : Wilt
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/06/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * This exception is thrown when Wilt has an internal error, such as an invalid
 * parameter being passed to a function.
 */

part of wilt;

class WiltException implements Exception {

  String _message = 'No Message Supplied';
  jsonobject.JsonObject _json;
  WiltException([this._message,this._json]);
  
  jsonobject.JsonObject get json => _json;

  String toString() => "WiltException: message = ${_message}, json = $_json";
}
