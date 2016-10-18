/*! jQuery Validation Plugin - v1.11.1 - 3/22/2013\n* https://github.com/jzaefferer/jquery-validation
 * Copyright (c) 2013 Jörn Zaefferer; Licensed MIT */
(function () {
  function t(t) {
    return t.replace(/<.[^<>]*?>/g, " ").replace(/&nbsp;|&#160;/gi, " ").replace(/[.(),;:!?%#$'"_+=\/\-]*/g, "")
  }

  jQuery.validator.addMethod("maxWords", function (e, i, a) {
    return this.optional(i) || a >= t(e).match(/\b\w+\b/g).length
  }, jQuery.validator.format("Please enter {0} words or less.")),

  jQuery.validator.addMethod("minWords", function (e, i, a) {
    return this.optional(i) || t(e).match(/\b\w+\b/g).length >= a
  }, jQuery.validator.format("Please enter at least {0} words.")), jQuery.validator.addMethod("rangeWords", function (e, i, a) {
    var r = t(e), n = /\b\w+\b/g;
    return this.optional(i) || r.match(n).length >= a[0] && r.match(n).length <= a[1]
  }, jQuery.validator.format("Please enter between {0} and {1} words."))
})(), jQuery.validator.addMethod("letterswithbasicpunc", function (t, e) {
  return this.optional(e) || /^[a-z\-.,()'"\s]+$/i.test(t)
}, "Letters or punctuation only please"), jQuery.validator.addMethod("alphanumeric", function (t, e) {
  return this.optional(e) || /^\w+$/i.test(t)
}, "Letters, numbers, and underscores only please"), jQuery.validator.addMethod("lettersonly", function (t, e) {
  return this.optional(e) || /^[a-z]+$/i.test(t)
}, "Letters only please"), jQuery.validator.addMethod("nowhitespace", function (t, e) {
  return this.optional(e) || /^\S+$/i.test(t)
}, "No white space please"), jQuery.validator.addMethod("ziprange", function (t, e) {
  return this.optional(e) || /^90[2-5]\d\{2\}-\d{4}$/.test(t)
}, "Your ZIP-code must be in the range 902xx-xxxx to 905-xx-xxxx"), jQuery.validator.addMethod("zipcodeUS", function (t, e) {
  return this.optional(e) || /\d{5}-\d{4}$|^\d{5}$/.test(t)
}, "The specified US ZIP Code is invalid"), jQuery.validator.addMethod("integer", function (t, e) {
  return this.optional(e) || /^-?\d+$/.test(t)
}, "A positive or negative non-decimal number please"), jQuery.validator.addMethod("vinUS", function (t) {
  if (17 !== t.length)return !1;
  var e, i, a, r, n, s, u = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"], d = [1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 7, 9, 2, 3, 4, 5, 6, 7, 8, 9], o = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2], l = 0;
  for (e = 0; 17 > e; e++) {
    if (r = o[e], a = t.slice(e, e + 1), 8 === e && (s = a), isNaN(a)) {
      for (i = 0; u.length > i; i++)if (a.toUpperCase() === u[i]) {
        a = d[i], a *= r, isNaN(s) && 8 === i && (s = u[i]);
        break
      }
    } else a *= r;
    l += a
  }
  return n = l % 11, 10 === n && (n = "X"), n === s ? !0 : !1
}, "The specified vehicle identification number (VIN) is invalid."), jQuery.validator.addMethod("dateITA", function (t, e) {
  var i = !1, a = /^\d{1,2}\/\d{1,2}\/\d{4}$/;
  if (a.test(t)) {
    var r = t.split("/"), n = parseInt(r[0], 10), s = parseInt(r[1], 10), u = parseInt(r[2], 10), d = new Date(u, s - 1, n);
    i = d.getFullYear() === u && d.getMonth() === s - 1 && d.getDate() === n ? !0 : !1
  } else i = !1;
  return this.optional(e) || i
}, "Please enter a correct date"), jQuery.validator.addMethod("iban", function (t, e) {
  if (this.optional(e))return !0;
  if (!/^([a-zA-Z0-9]{4} ){2,8}[a-zA-Z0-9]{1,4}|[a-zA-Z0-9]{12,34}$/.test(t))return !1;
  var i = t.replace(/ /g, "").toUpperCase(), a = i.substring(0, 2), r = {
    AL: "\\d{8}[\\dA-Z]{16}",
    AD: "\\d{8}[\\dA-Z]{12}",
    AT: "\\d{16}",
    AZ: "[\\dA-Z]{4}\\d{20}",
    BE: "\\d{12}",
    BH: "[A-Z]{4}[\\dA-Z]{14}",
    BA: "\\d{16}",
    BR: "\\d{23}[A-Z][\\dA-Z]",
    BG: "[A-Z]{4}\\d{6}[\\dA-Z]{8}",
    CR: "\\d{17}",
    HR: "\\d{17}",
    CY: "\\d{8}[\\dA-Z]{16}",
    CZ: "\\d{20}",
    DK: "\\d{14}",
    DO: "[A-Z]{4}\\d{20}",
    EE: "\\d{16}",
    FO: "\\d{14}",
    FI: "\\d{14}",
    FR: "\\d{10}[\\dA-Z]{11}\\d{2}",
    GE: "[\\dA-Z]{2}\\d{16}",
    DE: "\\d{18}",
    GI: "[A-Z]{4}[\\dA-Z]{15}",
    GR: "\\d{7}[\\dA-Z]{16}",
    GL: "\\d{14}",
    GT: "[\\dA-Z]{4}[\\dA-Z]{20}",
    HU: "\\d{24}",
    IS: "\\d{22}",
    IE: "[\\dA-Z]{4}\\d{14}",
    IL: "\\d{19}",
    IT: "[A-Z]\\d{10}[\\dA-Z]{12}",
    KZ: "\\d{3}[\\dA-Z]{13}",
    KW: "[A-Z]{4}[\\dA-Z]{22}",
    LV: "[A-Z]{4}[\\dA-Z]{13}",
    LB: "\\d{4}[\\dA-Z]{20}",
    LI: "\\d{5}[\\dA-Z]{12}",
    LT: "\\d{16}",
    LU: "\\d{3}[\\dA-Z]{13}",
    MK: "\\d{3}[\\dA-Z]{10}\\d{2}",
    MT: "[A-Z]{4}\\d{5}[\\dA-Z]{18}",
    MR: "\\d{23}",
    MU: "[A-Z]{4}\\d{19}[A-Z]{3}",
    MC: "\\d{10}[\\dA-Z]{11}\\d{2}",
    MD: "[\\dA-Z]{2}\\d{18}",
    ME: "\\d{18}",
    NL: "[A-Z]{4}\\d{10}",
    NO: "\\d{11}",
    PK: "[\\dA-Z]{4}\\d{16}",
    PS: "[\\dA-Z]{4}\\d{21}",
    PL: "\\d{24}",
    PT: "\\d{21}",
    RO: "[A-Z]{4}[\\dA-Z]{16}",
    SM: "[A-Z]\\d{10}[\\dA-Z]{12}",
    SA: "\\d{2}[\\dA-Z]{18}",
    RS: "\\d{18}",
    SK: "\\d{20}",
    SI: "\\d{15}",
    ES: "\\d{20}",
    SE: "\\d{20}",
    CH: "\\d{5}[\\dA-Z]{12}",
    TN: "\\d{20}",
    TR: "\\d{5}[\\dA-Z]{17}",
    AE: "\\d{3}\\d{16}",
    GB: "[A-Z]{4}\\d{14}",
    VG: "[\\dA-Z]{4}\\d{16}"
  }, n = r[a];
  if (n !== void 0) {
    var s = RegExp("^[A-Z]{2}\\d{2}" + n + "$", "");
    if (!s.test(i))return !1
  }
  for (var u, d = i.substring(4, i.length) + i.substring(0, 4), o = "", l = !0, h = 0; d.length > h; h++)u = d.charAt(h), "0" !== u && (l = !1), l || (o += "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(u));
  for (var F = "", c = "", m = 0; o.length > m; m++) {
    var f = o.charAt(m);
    c = "" + F + f, F = c % 97
  }
  return 1 === F
}, "Please specify a valid IBAN"), jQuery.validator.addMethod("dateNL", function (t, e) {
  return this.optional(e) || /^(0?[1-9]|[12]\d|3[01])[\.\/\-](0?[1-9]|1[012])[\.\/\-]([12]\d)?(\d\d)$/.test(t)
}, "Please enter a correct date"), jQuery.validator.addMethod("phoneNL", function (t, e) {
  return this.optional(e) || /^((\+|00(\s|\s?\-\s?)?)31(\s|\s?\-\s?)?(\(0\)[\-\s]?)?|0)[1-9]((\s|\s?\-\s?)?[0-9]){8}$/.test(t)
}, "Please specify a valid phone number."), jQuery.validator.addMethod("mobileNL", function (t, e) {
  return this.optional(e) || /^((\+|00(\s|\s?\-\s?)?)31(\s|\s?\-\s?)?(\(0\)[\-\s]?)?|0)6((\s|\s?\-\s?)?[0-9]){8}$/.test(t)
}, "Please specify a valid mobile number"), jQuery.validator.addMethod("postalcodeNL", function (t, e) {
  return this.optional(e) || /^[1-9][0-9]{3}\s?[a-zA-Z]{2}$/.test(t)
}, "Please specify a valid postal code"), jQuery.validator.addMethod("bankaccountNL", function (t, e) {
  if (this.optional(e))return !0;
  if (!/^[0-9]{9}|([0-9]{2} ){3}[0-9]{3}$/.test(t))return !1;
  for (var i = t.replace(/ /g, ""), a = 0, r = i.length, n = 0; r > n; n++) {
    var s = r - n, u = i.substring(n, n + 1);
    a += s * u
  }
  return 0 === a % 11
}, "Please specify a valid bank account number"), jQuery.validator.addMethod("giroaccountNL", function (t, e) {
  return this.optional(e) || /^[0-9]{1,7}$/.test(t)
}, "Please specify a valid giro account number"), jQuery.validator.addMethod("bankorgiroaccountNL", function (t, e) {
  return this.optional(e) || $.validator.methods.bankaccountNL.call(this, t, e) || $.validator.methods.giroaccountNL.call(this, t, e)
}, "Please specify a valid bank or giro account number"), jQuery.validator.addMethod("time", function (t, e) {
  return this.optional(e) || /^([01]\d|2[0-3])(:[0-5]\d){1,2}$/.test(t)
}, "Please enter a valid time, between 00:00 and 23:59"), jQuery.validator.addMethod("time12h", function (t, e) {
  return this.optional(e) || /^((0?[1-9]|1[012])(:[0-5]\d){1,2}(\ ?[AP]M))$/i.test(t)
}, "Please enter a valid time in 12-hour am/pm format"), jQuery.validator.addMethod("phoneUS", function (t, e) {
  return t = t.replace(/\s+/g, ""), this.optional(e) || t.length > 9 && t.match(/^(\+?1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/)
}, "Please specify a valid phone number"), jQuery.validator.addMethod("phoneUK", function (t, e) {
  return t = t.replace(/\(|\)|\s+|-/g, ""), this.optional(e) || t.length > 9 && t.match(/^(?:(?:(?:00\s?|\+)44\s?)|(?:\(?0))(?:\d{2}\)?\s?\d{4}\s?\d{4}|\d{3}\)?\s?\d{3}\s?\d{3,4}|\d{4}\)?\s?(?:\d{5}|\d{3}\s?\d{3})|\d{5}\)?\s?\d{4,5})$/)
}, "Please specify a valid phone number"), jQuery.validator.addMethod("mobileUK", function (t, e) {
  return t = t.replace(/\(|\)|\s+|-/g, ""), this.optional(e) || t.length > 9 && t.match(/^(?:(?:(?:00\s?|\+)44\s?|0)7(?:[45789]\d{2}|624)\s?\d{3}\s?\d{3})$/)
}, "Please specify a valid mobile number"), jQuery.validator.addMethod("phonesUK", function (t, e) {
  return t = t.replace(/\(|\)|\s+|-/g, ""), this.optional(e) || t.length > 9 && t.match(/^(?:(?:(?:00\s?|\+)44\s?|0)(?:1\d{8,9}|[23]\d{9}|7(?:[45789]\d{8}|624\d{6})))$/)
}, "Please specify a valid uk phone number"), jQuery.validator.addMethod("postcodeUK", function (t, e) {
  return this.optional(e) || /^((([A-PR-UWYZ][0-9])|([A-PR-UWYZ][0-9][0-9])|([A-PR-UWYZ][A-HK-Y][0-9])|([A-PR-UWYZ][A-HK-Y][0-9][0-9])|([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY]))\s?([0-9][ABD-HJLNP-UW-Z]{2})|(GIR)\s?(0AA))$/i.test(t)
}, "Please specify a valid UK postcode"), jQuery.validator.addMethod("strippedminlength", function (t, e, i) {
  return jQuery(t).text().length >= i
}, jQuery.validator.format("Please enter at least {0} characters")), jQuery.validator.addMethod("email2", function (t, e) {
  return this.optional(e) || /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test(t)
}, jQuery.validator.messages.email), jQuery.validator.addMethod("url2", function (t, e) {
  return this.optional(e) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(t)
}, jQuery.validator.messages.url), jQuery.validator.addMethod("creditcardtypes", function (t, e, i) {
  if (/[^0-9\-]+/.test(t))return !1;
  t = t.replace(/\D/g, "");
  var a = 0;
  return i.mastercard && (a |= 1), i.visa && (a |= 2), i.amex && (a |= 4), i.dinersclub && (a |= 8), i.enroute && (a |= 16), i.discover && (a |= 32), i.jcb && (a |= 64), i.unknown && (a |= 128), i.all && (a = 255), 1 & a && /^(5[12345])/.test(t) ? 16 === t.length : 2 & a && /^(4)/.test(t) ? 16 === t.length : 4 & a && /^(3[47])/.test(t) ? 15 === t.length : 8 & a && /^(3(0[012345]|[68]))/.test(t) ? 14 === t.length : 16 & a && /^(2(014|149))/.test(t) ? 15 === t.length : 32 & a && /^(6011)/.test(t) ? 16 === t.length : 64 & a && /^(3)/.test(t) ? 16 === t.length : 64 & a && /^(2131|1800)/.test(t) ? 15 === t.length : 128 & a ? !0 : !1
}, "Please enter a valid credit card number."), jQuery.validator.addMethod("ipv4", function (t, e) {
  return this.optional(e) || /^(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)$/i.test(t)
}, "Please enter a valid IP v4 address."), jQuery.validator.addMethod("ipv6", function (t, e) {
  return this.optional(e) || /^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$/i.test(t)
}, "Please enter a valid IP v6 address."), jQuery.validator.addMethod("pattern", function (t, e, i) {
  return this.optional(e) ? !0 : ("string" == typeof i && (i = RegExp("^(?:" + i + ")$")), i.test(t))
}, "Invalid format."), jQuery.validator.addMethod("require_from_group", function (t, e, i) {
  var a = this, r = i[1], n = $(r, e.form).filter(function () {
      return a.elementValue(this)
    }).length >= i[0];
  if (!$(e).data("being_validated")) {
    var s = $(r, e.form);
    s.data("being_validated", !0), s.valid(), s.data("being_validated", !1)
  }
  return n
}, jQuery.format("Please fill at least {0} of these fields.")), jQuery.validator.addMethod("skip_or_fill_minimum", function (t, e, i) {
  var a = this, r = i[0], n = i[1], s = $(n, e.form).filter(function () {
    return a.elementValue(this)
  }).length, u = s >= r || 0 === s;
  if (!$(e).data("being_validated")) {
    var d = $(n, e.form);
    d.data("being_validated", !0), d.valid(), d.data("being_validated", !1)
  }
  return u
}, jQuery.format("Please either skip these fields or fill at least {0} of them.")), jQuery.validator.addMethod("accept", function (t, e, i) {
  var a, r, n = "string" == typeof i ? i.replace(/\s/g, "").replace(/,/g, "|") : "image/*", s = this.optional(e);
  if (s)return s;
  if ("file" === $(e).attr("type") && (n = n.replace(/\*/g, ".*"), e.files && e.files.length))for (a = 0; e.files.length > a; a++)if (r = e.files[a], !r.type.match(RegExp(".?(" + n + ")$", "i")))return !1;
  return !0
}, jQuery.format("Please enter a value with a valid mimetype.")),

jQuery.validator.addMethod("extension", function (t, e, i) {
  return i = "string" == typeof i ? i.replace(/,/g, "|") : "png|jpe?g|gif", this.optional(e) || t.match(RegExp(".(" + i + ")$", "i"))
}, jQuery.format("Please enter a value with a valid extension.")),

  jQuery.validator.addMethod("mobileCN", function(phone_number, element) {
    return this.optional(element) || phone_number.match(/^1\d{10}$/);
  }, jQuery.format("请输入有效的手机号码"));