import 'package:flutter/foundation.dart';

/// A country definition with image asset, dialing code and localized name.
class Country {
  /// the flag image asset name
  final String asset;

  /// the dialing code
  final String dialingCode;

  /// the 2-letter ISO code
  final String isoCode;

  /// the localized / English country name
  final String name;

  /// Instantiates an [Country] with the specified [asset], [dialingCode] and [isoCode]
  const Country({
    @required this.asset,
    @required this.dialingCode,
    @required this.isoCode,
    this.name = "",
  });

  @override
  bool operator ==(o) =>
      o is Country &&
      o.dialingCode == this.dialingCode &&
      o.isoCode == this.isoCode &&
      o.asset == this.asset &&
      o.name == this.name;

  int get hashCode {
    int hash = 7;
    hash = 31 * hash + this.dialingCode.hashCode;
    hash = 31 * hash + this.asset.hashCode;
    hash = 31 * hash + this.name.hashCode;
    hash = 31 * hash + this.isoCode.hashCode;
    return hash;
  }

  static const Country AD = Country(
    asset: "assets/flags/ad_flag.png",
    dialingCode: "376",
    isoCode: "AD",
    name: "Andorra",
  );
  static const Country AE = Country(
    asset: "assets/flags/ae_flag.png",
    dialingCode: "971",
    isoCode: "AE",
    name: "United Arab Emirates",
  );
  static const Country AF = Country(
    asset: "assets/flags/af_flag.png",
    dialingCode: "93",
    isoCode: "AF",
    name: "Afghanistan",
  );
  static const Country AG = Country(
    asset: "assets/flags/ag_flag.png",
    dialingCode: "1",
    isoCode: "AG",
    name: "Antigua and Barbuda",
  );
  static const Country AI = Country(
    asset: "assets/flags/ai_flag.png",
    dialingCode: "1",
    isoCode: "AI",
    name: "Anguilla",
  );
  static const Country AL = Country(
    asset: "assets/flags/al_flag.png",
    dialingCode: "355",
    isoCode: "AL",
    name: "Albania",
  );
  static const Country AM = Country(
    asset: "assets/flags/am_flag.png",
    dialingCode: "374",
    isoCode: "AM",
    name: "Armenia",
  );
  static const Country AO = Country(
    asset: "assets/flags/ao_flag.png",
    dialingCode: "244",
    isoCode: "AO",
    name: "Angola",
  );
  static const Country AQ = Country(
    asset: "assets/flags/aq_flag.png",
    dialingCode: "672",
    isoCode: "AQ",
    name: "Antarctica",
  );
  static const Country AR = Country(
    asset: "assets/flags/ar_flag.png",
    dialingCode: "54",
    isoCode: "AR",
    name: "Argentina",
  );
  static const Country AS = Country(
    asset: "assets/flags/as_flag.png",
    dialingCode: "1",
    isoCode: "AS",
    name: "American Samoa",
  );
  static const Country AT = Country(
    asset: "assets/flags/at_flag.png",
    dialingCode: "43",
    isoCode: "AT",
    name: "Austria",
  );
  static const Country AU = Country(
    asset: "assets/flags/au_flag.png",
    dialingCode: "61",
    isoCode: "AU",
    name: "Australia",
  );
  static const Country AW = Country(
    asset: "assets/flags/aw_flag.png",
    dialingCode: "297",
    isoCode: "AW",
    name: "Aruba",
  );
  static const Country AX = Country(
    asset: "assets/flags/ax_flag.png",
    dialingCode: "358",
    isoCode: "AX",
    name: "Aaland Islands",
  );
  static const Country AZ = Country(
    asset: "assets/flags/az_flag.png",
    dialingCode: "994",
    isoCode: "AZ",
    name: "Azerbaijan",
  );
  static const Country BA = Country(
    asset: "assets/flags/ba_flag.png",
    dialingCode: "387",
    isoCode: "BA",
    name: "Bosnia and Herzegowina",
  );
  static const Country BB = Country(
    asset: "assets/flags/bb_flag.png",
    dialingCode: "1",
    isoCode: "BB",
    name: "Barbados",
  );
  static const Country BD = Country(
    asset: "assets/flags/bd_flag.png",
    dialingCode: "880",
    isoCode: "BD",
    name: "Bangladesh",
  );
  static const Country BE = Country(
    asset: "assets/flags/be_flag.png",
    dialingCode: "32",
    isoCode: "BE",
    name: "Belgium",
  );
  static const Country BF = Country(
    asset: "assets/flags/bf_flag.png",
    dialingCode: "226",
    isoCode: "BF",
    name: "Burkina Faso",
  );
  static const Country BG = Country(
    asset: "assets/flags/bg_flag.png",
    dialingCode: "359",
    isoCode: "BG",
    name: "Bulgaria",
  );
  static const Country BH = Country(
    asset: "assets/flags/bh_flag.png",
    dialingCode: "973",
    isoCode: "BH",
    name: "Bahrain",
  );
  static const Country BI = Country(
    asset: "assets/flags/bi_flag.png",
    dialingCode: "257",
    isoCode: "BI",
    name: "Burundi",
  );
  static const Country BJ = Country(
    asset: "assets/flags/bj_flag.png",
    dialingCode: "229",
    isoCode: "BJ",
    name: "Benin",
  );
  static const Country BL = Country(
    asset: "assets/flags/bl_flag.png",
    dialingCode: "590",
    isoCode: "BL",
    name: "Saint-Barthélemy",
  );
  static const Country BM = Country(
    asset: "assets/flags/bm_flag.png",
    dialingCode: "1",
    isoCode: "BM",
    name: "Bermuda",
  );
  static const Country BN = Country(
    asset: "assets/flags/bn_flag.png",
    dialingCode: "673",
    isoCode: "BN",
    name: "Brunei Darussalam",
  );
  static const Country BO = Country(
    asset: "assets/flags/bo_flag.png",
    dialingCode: "591",
    isoCode: "BO",
    name: "Bolivia",
  );
  static const Country BQ = Country(
    asset: "assets/flags/bq_flag.png",
    dialingCode: "599",
    isoCode: "BQ",
    name: "Bonaire, Sint Eustatius and Saba",
  );
  static const Country BR = Country(
    asset: "assets/flags/br_flag.png",
    dialingCode: "55",
    isoCode: "BR",
    name: "Brazil",
  );
  static const Country BS = Country(
    asset: "assets/flags/bs_flag.png",
    dialingCode: "1",
    isoCode: "BS",
    name: "Bahamas",
  );
  static const Country BT = Country(
    asset: "assets/flags/bt_flag.png",
    dialingCode: "975",
    isoCode: "BT",
    name: "Bhutan",
  );
  static const Country BV = Country(
    asset: "assets/flags/bv_flag.png",
    dialingCode: "55",
    isoCode: "BV",
    name: "Bouvet Island",
  );
  static const Country BW = Country(
    asset: "assets/flags/bw_flag.png",
    dialingCode: "267",
    isoCode: "BW",
    name: "Botswana",
  );
  static const Country BY = Country(
    asset: "assets/flags/by_flag.png",
    dialingCode: "375",
    isoCode: "BY",
    name: "Belarus",
  );
  static const Country BZ = Country(
    asset: "assets/flags/bz_flag.png",
    dialingCode: "501",
    isoCode: "BZ",
    name: "Belize",
  );
  static const Country CA = Country(
    asset: "assets/flags/ca_flag.png",
    dialingCode: "1",
    isoCode: "CA",
    name: "Canada",
  );
  static const Country CC = Country(
    asset: "assets/flags/cc_flag.png",
    dialingCode: "891",
    isoCode: "CC",
    name: "Cocos (Keeling) Islands",
  );
  static const Country CD = Country(
    asset: "assets/flags/cd_flag.png",
    dialingCode: "243",
    isoCode: "CD",
    name: "Congo, Democratic Republic Of (Was Zaire)",
  );
  static const Country CF = Country(
    asset: "assets/flags/cf_flag.png",
    dialingCode: "236",
    isoCode: "CF",
    name: "Central African Republic",
  );
  static const Country CG = Country(
    asset: "assets/flags/cg_flag.png",
    dialingCode: "242",
    isoCode: "CG",
    name: "Congo, Republic Of",
  );
  static const Country CH = Country(
    asset: "assets/flags/ch_flag.png",
    dialingCode: "41",
    isoCode: "CH",
    name: "Switzerland",
  );
  static const Country CI = Country(
    asset: "assets/flags/ci_flag.png",
    dialingCode: "225",
    isoCode: "CI",
    name: "Cote D'ivoire",
  );
  static const Country CK = Country(
    asset: "assets/flags/ck_flag.png",
    dialingCode: "682",
    isoCode: "CK",
    name: "Cook Islands",
  );
  static const Country CL = Country(
    asset: "assets/flags/cl_flag.png",
    dialingCode: "56",
    isoCode: "CL",
    name: "Chile",
  );
  static const Country CM = Country(
    asset: "assets/flags/cm_flag.png",
    dialingCode: "237",
    isoCode: "CM",
    name: "Cameroon",
  );
  static const Country CN = Country(
    asset: "assets/flags/cn_flag.png",
    dialingCode: "86",
    isoCode: "CN",
    name: "China",
  );
  static const Country CO = Country(
    asset: "assets/flags/co_flag.png",
    dialingCode: "57",
    isoCode: "CO",
    name: "Colombia",
  );
  static const Country CR = Country(
    asset: "assets/flags/cr_flag.png",
    dialingCode: "506",
    isoCode: "CR",
    name: "Costa Rica",
  );
  static const Country CU = Country(
    asset: "assets/flags/cu_flag.png",
    dialingCode: "53",
    isoCode: "CU",
    name: "Cuba",
  );
  static const Country CV = Country(
    asset: "assets/flags/cv_flag.png",
    dialingCode: "238",
    isoCode: "CV",
    name: "Cape Verde",
  );
  static const Country CW = Country(
    asset: "assets/flags/cw_flag.png",
    dialingCode: "599",
    isoCode: "CW",
    name: "Curaçao",
  );
  static const Country CX = Country(
    asset: "assets/flags/cx_flag.png",
    dialingCode: "61",
    isoCode: "CX",
    name: "Christmas Island",
  );
  static const Country CY = Country(
    asset: "assets/flags/cy_flag.png",
    dialingCode: "357",
    isoCode: "CY",
    name: "Cyprus",
  );
  static const Country CZ = Country(
    asset: "assets/flags/cz_flag.png",
    dialingCode: "420",
    isoCode: "CZ",
    name: "Czech Republic",
  );
  static const Country DE = Country(
    asset: "assets/flags/de_flag.png",
    dialingCode: "49",
    isoCode: "DE",
    name: "Germany",
  );
  static const Country DJ = Country(
    asset: "assets/flags/dj_flag.png",
    dialingCode: "253",
    isoCode: "DJ",
    name: "Djibouti",
  );
  static const Country DK = Country(
    asset: "assets/flags/dk_flag.png",
    dialingCode: "45",
    isoCode: "DK",
    name: "Denmark",
  );
  static const Country DM = Country(
    asset: "assets/flags/dm_flag.png",
    dialingCode: "1",
    isoCode: "DM",
    name: "Dominica",
  );
  static const Country DO = Country(
    asset: "assets/flags/do_flag.png",
    dialingCode: "1",
    isoCode: "DO",
    name: "Dominican Republic",
  );
  static const Country DZ = Country(
    asset: "assets/flags/dz_flag.png",
    dialingCode: "213",
    isoCode: "DZ",
    name: "Algeria",
  );
  static const Country EC = Country(
    asset: "assets/flags/ec_flag.png",
    dialingCode: "593",
    isoCode: "EC",
    name: "Ecuador",
  );
  static const Country EE = Country(
    asset: "assets/flags/ee_flag.png",
    dialingCode: "372",
    isoCode: "EE",
    name: "Estonia",
  );
  static const Country EG = Country(
    asset: "assets/flags/eg_flag.png",
    dialingCode: "20",
    isoCode: "EG",
    name: "Egypt",
  );
  static const Country EH = Country(
    asset: "assets/flags/eh_flag.png",
    dialingCode: "212",
    isoCode: "EH",
    name: "Western Sahara",
  );
  static const Country ER = Country(
    asset: "assets/flags/er_flag.png",
    dialingCode: "291",
    isoCode: "ER",
    name: "Eritrea",
  );
  static const Country ES = Country(
    asset: "assets/flags/es_flag.png",
    dialingCode: "34",
    isoCode: "ES",
    name: "Spain",
  );
  static const Country ET = Country(
    asset: "assets/flags/et_flag.png",
    dialingCode: "251",
    isoCode: "ET",
    name: "Ethiopia",
  );
  static const Country FI = Country(
    asset: "assets/flags/fi_flag.png",
    dialingCode: "358",
    isoCode: "FI",
    name: "Finland",
  );
  static const Country FJ = Country(
    asset: "assets/flags/fj_flag.png",
    dialingCode: "679",
    isoCode: "FJ",
    name: "Fiji",
  );
  static const Country FK = Country(
    asset: "assets/flags/fk_flag.png",
    dialingCode: "500",
    isoCode: "FK",
    name: "Falkland Islands (Malvinas)",
  );
  static const Country FM = Country(
    asset: "assets/flags/fm_flag.png",
    dialingCode: "691",
    isoCode: "FM",
    name: "Micronesia, Federated States Of",
  );
  static const Country FO = Country(
    asset: "assets/flags/fo_flag.png",
    dialingCode: "298",
    isoCode: "FO",
    name: "Faroe Islands",
  );
  static const Country FR = Country(
    asset: "assets/flags/fr_flag.png",
    dialingCode: "33",
    isoCode: "FR",
    name: "France",
  );
  static const Country GA = Country(
    asset: "assets/flags/ga_flag.png",
    dialingCode: "241",
    isoCode: "GA",
    name: "Gabon",
  );
  static const Country GB = Country(
    asset: "assets/flags/gb_flag.png",
    dialingCode: "44",
    isoCode: "GB",
    name: "United Kingdom",
  );
  static const Country GD = Country(
    asset: "assets/flags/gd_flag.png",
    dialingCode: "1",
    isoCode: "GD",
    name: "Grenada",
  );
  static const Country GE = Country(
    asset: "assets/flags/ge_flag.png",
    dialingCode: "995",
    isoCode: "GE",
    name: "Georgia",
  );
  static const Country GF = Country(
    asset: "assets/flags/gf_flag.png",
    dialingCode: "594",
    isoCode: "GF",
    name: "French Guiana",
  );
  static const Country GG = Country(
    asset: "assets/flags/gg_flag.png",
    dialingCode: "44",
    isoCode: "GG",
    name: "Guernsey",
  );
  static const Country GH = Country(
    asset: "assets/flags/gh_flag.png",
    dialingCode: "233",
    isoCode: "GH",
    name: "Ghana",
  );
  static const Country GI = Country(
    asset: "assets/flags/gi_flag.png",
    dialingCode: "350",
    isoCode: "GI",
    name: "Gibraltar",
  );
  static const Country GL = Country(
    asset: "assets/flags/gl_flag.png",
    dialingCode: "299",
    isoCode: "GL",
    name: "Greenland",
  );
  static const Country GM = Country(
    asset: "assets/flags/gm_flag.png",
    dialingCode: "220",
    isoCode: "GM",
    name: "Gambia",
  );
  static const Country GN = Country(
    asset: "assets/flags/gn_flag.png",
    dialingCode: "224",
    isoCode: "GN",
    name: "Guinea",
  );
  static const Country GP = Country(
    asset: "assets/flags/gp_flag.png",
    dialingCode: "590",
    isoCode: "GP",
    name: "Guadeloupe",
  );
  static const Country GQ = Country(
    asset: "assets/flags/gq_flag.png",
    dialingCode: "240",
    isoCode: "GQ",
    name: "Equatorial Guinea",
  );
  static const Country GR = Country(
    asset: "assets/flags/gr_flag.png",
    dialingCode: "30",
    isoCode: "GR",
    name: "Greece",
  );
  static const Country GS = Country(
    asset: "assets/flags/gs_flag.png",
    dialingCode: "500",
    isoCode: "GS",
    name: "South Georgia and The South Sandwich Islands",
  );
  static const Country GT = Country(
    asset: "assets/flags/gt_flag.png",
    dialingCode: "502",
    isoCode: "GT",
    name: "Guatemala",
  );
  static const Country GU = Country(
    asset: "assets/flags/gu_flag.png",
    dialingCode: "1",
    isoCode: "GU",
    name: "Guam",
  );
  static const Country GW = Country(
    asset: "assets/flags/gw_flag.png",
    dialingCode: "245",
    isoCode: "GW",
    name: "Guinea-bissau",
  );
  static const Country GY = Country(
    asset: "assets/flags/gy_flag.png",
    dialingCode: "592",
    isoCode: "GY",
    name: "Guyana",
  );
  static const Country HK = Country(
    asset: "assets/flags/hk_flag.png",
    dialingCode: "852",
    isoCode: "HK",
    name: "Hong Kong",
  );
  static const Country HM = Country(
    asset: "assets/flags/hm_flag.png",
    dialingCode: "61",
    isoCode: "HM",
    name: "Heard and Mc Donald Islands",
  );
  static const Country HN = Country(
    asset: "assets/flags/hn_flag.png",
    dialingCode: "504",
    isoCode: "HN",
    name: "Honduras",
  );
  static const Country HR = Country(
    asset: "assets/flags/hr_flag.png",
    dialingCode: "385",
    isoCode: "HR",
    name: "Croatia (Local Name: Hrvatska)",
  );
  static const Country HT = Country(
    asset: "assets/flags/ht_flag.png",
    dialingCode: "509",
    isoCode: "HT",
    name: "Haiti",
  );
  static const Country HU = Country(
    asset: "assets/flags/hu_flag.png",
    dialingCode: "36",
    isoCode: "HU",
    name: "Hungary",
  );
  static const Country ID = Country(
    asset: "assets/flags/id_flag.png",
    dialingCode: "62",
    isoCode: "ID",
    name: "Indonesia",
  );
  static const Country IE = Country(
    asset: "assets/flags/ie_flag.png",
    dialingCode: "353",
    isoCode: "IE",
    name: "Ireland",
  );
  static const Country IL = Country(
    asset: "assets/flags/il_flag.png",
    dialingCode: "972",
    isoCode: "IL",
    name: "Israel",
  );
  static const Country IM = Country(
    asset: "assets/flags/im_flag.png",
    dialingCode: "44",
    isoCode: "IM",
    name: "Isle of Man",
  );
  static const Country IN = Country(
    asset: "assets/flags/in_flag.png",
    dialingCode: "91",
    isoCode: "IN",
    name: "India",
  );
  static const Country IO = Country(
    asset: "assets/flags/io_flag.png",
    dialingCode: "246",
    isoCode: "IO",
    name: "British Indian Ocean Territory",
  );
  static const Country IQ = Country(
    asset: "assets/flags/iq_flag.png",
    dialingCode: "964",
    isoCode: "IQ",
    name: "Iraq",
  );
  static const Country IR = Country(
    asset: "assets/flags/ir_flag.png",
    dialingCode: "98",
    isoCode: "IR",
    name: "Iran (Islamic Republic Of)",
  );
  static const Country IS = Country(
    asset: "assets/flags/is_flag.png",
    dialingCode: "354",
    isoCode: "IS",
    name: "Iceland",
  );
  static const Country IT = Country(
    asset: "assets/flags/it_flag.png",
    dialingCode: "39",
    isoCode: "IT",
    name: "Italy",
  );
  static const Country JE = Country(
    asset: "assets/flags/je_flag.png",
    dialingCode: "44",
    isoCode: "JE",
    name: "Jersey",
  );
  static const Country JM = Country(
    asset: "assets/flags/jm_flag.png",
    dialingCode: "1",
    isoCode: "JM",
    name: "Jamaica",
  );
  static const Country JO = Country(
    asset: "assets/flags/jo_flag.png",
    dialingCode: "962",
    isoCode: "JO",
    name: "Jordan",
  );
  static const Country JP = Country(
    asset: "assets/flags/jp_flag.png",
    dialingCode: "81",
    isoCode: "JP",
    name: "Japan",
  );
  static const Country KE = Country(
    asset: "assets/flags/ke_flag.png",
    dialingCode: "254",
    isoCode: "KE",
    name: "Kenya",
  );
  static const Country KG = Country(
    asset: "assets/flags/kg_flag.png",
    dialingCode: "996",
    isoCode: "KG",
    name: "Kyrgyzstan",
  );
  static const Country KH = Country(
    asset: "assets/flags/kh_flag.png",
    dialingCode: "855",
    isoCode: "KH",
    name: "Cambodia",
  );
  static const Country KI = Country(
    asset: "assets/flags/ki_flag.png",
    dialingCode: "686",
    isoCode: "KI",
    name: "Kiribati",
  );
  static const Country KM = Country(
    asset: "assets/flags/km_flag.png",
    dialingCode: "269",
    isoCode: "KM",
    name: "Comoros",
  );
  static const Country KN = Country(
    asset: "assets/flags/kn_flag.png",
    dialingCode: "1",
    isoCode: "KN",
    name: "Saint Kitts and Nevis",
  );
  static const Country KP = Country(
    asset: "assets/flags/kp_flag.png",
    dialingCode: "850",
    isoCode: "KP",
    name: "Korea, Democratic People's Republic Of",
  );
  static const Country KR = Country(
    asset: "assets/flags/kr_flag.png",
    dialingCode: "82",
    isoCode: "KR",
    name: "Korea, Republic Of",
  );
  static const Country KW = Country(
    asset: "assets/flags/kw_flag.png",
    dialingCode: "965",
    isoCode: "KW",
    name: "Kuwait",
  );
  static const Country KY = Country(
    asset: "assets/flags/ky_flag.png",
    dialingCode: "965",
    isoCode: "KY",
    name: "Cayman Islands",
  );
  static const Country KZ = Country(
    asset: "assets/flags/kz_flag.png",
    dialingCode: "7",
    isoCode: "KZ",
    name: "Kazakhstan",
  );
  static const Country LA = Country(
    asset: "assets/flags/la_flag.png",
    dialingCode: "856",
    isoCode: "LA",
    name: "Lao People's Democratic Republic",
  );
  static const Country LB = Country(
    asset: "assets/flags/lb_flag.png",
    dialingCode: "961",
    isoCode: "LB",
    name: "Lebanon",
  );
  static const Country LC = Country(
    asset: "assets/flags/lc_flag.png",
    dialingCode: "1",
    isoCode: "LC",
    name: "Saint Lucia",
  );
  static const Country LI = Country(
    asset: "assets/flags/li_flag.png",
    dialingCode: "423",
    isoCode: "LI",
    name: "Liechtenstein",
  );
  static const Country LK = Country(
    asset: "assets/flags/lk_flag.png",
    dialingCode: "94",
    isoCode: "LK",
    name: "Sri Lanka",
  );
  static const Country LR = Country(
    asset: "assets/flags/lr_flag.png",
    dialingCode: "231",
    isoCode: "LR",
    name: "Liberia",
  );
  static const Country LS = Country(
    asset: "assets/flags/ls_flag.png",
    dialingCode: "266",
    isoCode: "LS",
    name: "Lesotho",
  );
  static const Country LT = Country(
    asset: "assets/flags/lt_flag.png",
    dialingCode: "370",
    isoCode: "LT",
    name: "Lithuania",
  );
  static const Country LU = Country(
    asset: "assets/flags/lu_flag.png",
    dialingCode: "352",
    isoCode: "LU",
    name: "Luxembourg",
  );
  static const Country LV = Country(
    asset: "assets/flags/lv_flag.png",
    dialingCode: "371",
    isoCode: "LV",
    name: "Latvia",
  );
  static const Country LY = Country(
    asset: "assets/flags/ly_flag.png",
    dialingCode: "218",
    isoCode: "LY",
    name: "Libyan Arab Jamahiriya",
  );
  static const Country MA = Country(
    asset: "assets/flags/ma_flag.png",
    dialingCode: "212",
    isoCode: "MA",
    name: "Morocco",
  );
  static const Country MC = Country(
    asset: "assets/flags/mc_flag.png",
    dialingCode: "377",
    isoCode: "MC",
    name: "Monaco",
  );
  static const Country MD = Country(
    asset: "assets/flags/md_flag.png",
    dialingCode: "373",
    isoCode: "MD",
    name: "Moldova, Republic Of",
  );
  static const Country ME = Country(
    asset: "assets/flags/me_flag.png",
    dialingCode: "382",
    isoCode: "ME",
    name: "Montenegro",
  );
  static const Country MF = Country(
    asset: "assets/flags/mf_flag.png",
    dialingCode: "1",
    isoCode: "MF",
    name: "Saint-Martin",
  );
  static const Country MG = Country(
    asset: "assets/flags/mg_flag.png",
    dialingCode: "261",
    isoCode: "MG",
    name: "Madagascar",
  );
  static const Country MH = Country(
    asset: "assets/flags/mh_flag.png",
    dialingCode: "692",
    isoCode: "MH",
    name: "Marshall Islands",
  );
  static const Country MK = Country(
    asset: "assets/flags/mk_flag.png",
    dialingCode: "389",
    isoCode: "MK",
    name: "Macedonia, The Former Yugoslav Republic Of",
  );
  static const Country ML = Country(
    asset: "assets/flags/ml_flag.png",
    dialingCode: "223",
    isoCode: "ML",
    name: "Mali",
  );
  static const Country MM = Country(
    asset: "assets/flags/mm_flag.png",
    dialingCode: "95",
    isoCode: "MM",
    name: "Myanmar",
  );
  static const Country MN = Country(
    asset: "assets/flags/mn_flag.png",
    dialingCode: "976",
    isoCode: "MN",
    name: "Mongolia",
  );
  static const Country MO = Country(
    asset: "assets/flags/mo_flag.png",
    dialingCode: "853",
    isoCode: "MO",
    name: "Macau",
  );
  static const Country MP = Country(
    asset: "assets/flags/mp_flag.png",
    dialingCode: "1",
    isoCode: "MP",
    name: "Northern Mariana Islands",
  );
  static const Country MQ = Country(
    asset: "assets/flags/mq_flag.png",
    dialingCode: "596",
    isoCode: "MQ",
    name: "Martinique",
  );
  static const Country MR = Country(
    asset: "assets/flags/mr_flag.png",
    dialingCode: "222",
    isoCode: "MR",
    name: "Mauritania",
  );
  static const Country MS = Country(
    asset: "assets/flags/ms_flag.png",
    dialingCode: "1",
    isoCode: "MS",
    name: "Montserrat",
  );
  static const Country MT = Country(
    asset: "assets/flags/mt_flag.png",
    dialingCode: "356",
    isoCode: "MT",
    name: "Malta",
  );
  static const Country MU = Country(
    asset: "assets/flags/mu_flag.png",
    dialingCode: "230",
    isoCode: "MU",
    name: "Mauritius",
  );
  static const Country MV = Country(
    asset: "assets/flags/mv_flag.png",
    dialingCode: "960",
    isoCode: "MV",
    name: "Maldives",
  );
  static const Country MW = Country(
    asset: "assets/flags/mw_flag.png",
    dialingCode: "265",
    isoCode: "MW",
    name: "Malawi",
  );
  static const Country MX = Country(
    asset: "assets/flags/mx_flag.png",
    dialingCode: "52",
    isoCode: "MX",
    name: "Mexico",
  );
  static const Country MY = Country(
    asset: "assets/flags/my_flag.png",
    dialingCode: "60",
    isoCode: "MY",
    name: "Malaysia",
  );
  static const Country MZ = Country(
    asset: "assets/flags/mz_flag.png",
    dialingCode: "258",
    isoCode: "MZ",
    name: "Mozambique",
  );
  static const Country NA = Country(
    asset: "assets/flags/na_flag.png",
    dialingCode: "264",
    isoCode: "NA",
    name: "Namibia",
  );
  static const Country NC = Country(
    asset: "assets/flags/nc_flag.png",
    dialingCode: "687",
    isoCode: "NC",
    name: "New Caledonia",
  );
  static const Country NE = Country(
    asset: "assets/flags/ne_flag.png",
    dialingCode: "227",
    isoCode: "NE",
    name: "Niger",
  );
  static const Country NF = Country(
    asset: "assets/flags/nf_flag.png",
    dialingCode: "672",
    isoCode: "NF",
    name: "Norfolk Island",
  );
  static const Country NG = Country(
    asset: "assets/flags/ng_flag.png",
    dialingCode: "234",
    isoCode: "NG",
    name: "Nigeria",
  );
  static const Country NI = Country(
    asset: "assets/flags/ni_flag.png",
    dialingCode: "505",
    isoCode: "NI",
    name: "Nicaragua",
  );
  static const Country NL = Country(
    asset: "assets/flags/nl_flag.png",
    dialingCode: "31",
    isoCode: "NL",
    name: "Netherlands",
  );
  static const Country NO = Country(
    asset: "assets/flags/no_flag.png",
    dialingCode: "47",
    isoCode: "NO",
    name: "Norway",
  );
  static const Country NP = Country(
    asset: "assets/flags/np_flag.png",
    dialingCode: "977",
    isoCode: "NP",
    name: "Nepal",
  );
  static const Country NR = Country(
    asset: "assets/flags/nr_flag.png",
    dialingCode: "674",
    isoCode: "NR",
    name: "Nauru",
  );
  static const Country NU = Country(
    asset: "assets/flags/nu_flag.png",
    dialingCode: "683",
    isoCode: "NU",
    name: "Niue",
  );
  static const Country NZ = Country(
    asset: "assets/flags/nz_flag.png",
    dialingCode: "64",
    isoCode: "NZ",
    name: "New Zealand",
  );
  static const Country OM = Country(
    asset: "assets/flags/om_flag.png",
    dialingCode: "968",
    isoCode: "OM",
    name: "Oman",
  );
  static const Country PA = Country(
    asset: "assets/flags/pa_flag.png",
    dialingCode: "507",
    isoCode: "PA",
    name: "Panama",
  );
  static const Country PE = Country(
    asset: "assets/flags/pe_flag.png",
    dialingCode: "51",
    isoCode: "PE",
    name: "Peru",
  );
  static const Country PF = Country(
    asset: "assets/flags/pf_flag.png",
    dialingCode: "689",
    isoCode: "PF",
    name: "French Polynesia",
  );
  static const Country PG = Country(
    asset: "assets/flags/pg_flag.png",
    dialingCode: "675",
    isoCode: "PG",
    name: "Papua New Guinea",
  );
  static const Country PH = Country(
    asset: "assets/flags/ph_flag.png",
    dialingCode: "63",
    isoCode: "PH",
    name: "Philippines",
  );
  static const Country PK = Country(
    asset: "assets/flags/pk_flag.png",
    dialingCode: "92",
    isoCode: "PK",
    name: "Pakistan",
  );
  static const Country PL = Country(
    asset: "assets/flags/pl_flag.png",
    dialingCode: "48",
    isoCode: "PL",
    name: "Poland",
  );
  static const Country PM = Country(
    asset: "assets/flags/pm_flag.png",
    dialingCode: "508",
    isoCode: "PM",
    name: "Saint Pierre and Miquelon",
  );
  static const Country PN = Country(
    asset: "assets/flags/pn_flag.png",
    dialingCode: "64",
    isoCode: "PN",
    name: "Pitcairn",
  );
  static const Country PR = Country(
    asset: "assets/flags/pr_flag.png",
    dialingCode: "1",
    isoCode: "PR",
    name: "Puerto Rico",
  );
  static const Country PS = Country(
    asset: "assets/flags/ps_flag.png",
    dialingCode: "970",
    isoCode: "PS",
    name: "Palestinian Territory, Occupied",
  );
  static const Country PT = Country(
    asset: "assets/flags/pt_flag.png",
    dialingCode: "351",
    isoCode: "PT",
    name: "Portugal",
  );
  static const Country PW = Country(
    asset: "assets/flags/pw_flag.png",
    dialingCode: "680",
    isoCode: "PW",
    name: "Palau",
  );
  static const Country PY = Country(
    asset: "assets/flags/py_flag.png",
    dialingCode: "595",
    isoCode: "PY",
    name: "Paraguay",
  );
  static const Country QA = Country(
    asset: "assets/flags/qa_flag.png",
    dialingCode: "974",
    isoCode: "QA",
    name: "Qatar",
  );
  static const Country RE = Country(
    asset: "assets/flags/re_flag.png",
    dialingCode: "262",
    isoCode: "RE",
    name: "Reunion",
  );
  static const Country RO = Country(
    asset: "assets/flags/ro_flag.png",
    dialingCode: "40",
    isoCode: "RO",
    name: "Romania",
  );
  static const Country RS = Country(
    asset: "assets/flags/rs_flag.png",
    dialingCode: "381",
    isoCode: "RS",
    name: "Serbia",
  );
  static const Country RU = Country(
    asset: "assets/flags/ru_flag.png",
    dialingCode: "7",
    isoCode: "RU",
    name: "Russian Federation",
  );
  static const Country RW = Country(
    asset: "assets/flags/rw_flag.png",
    dialingCode: "250",
    isoCode: "RW",
    name: "Rwanda",
  );
  static const Country SA = Country(
    asset: "assets/flags/sa_flag.png",
    dialingCode: "966",
    isoCode: "SA",
    name: "Saudi Arabia",
  );
  static const Country SB = Country(
    asset: "assets/flags/sb_flag.png",
    dialingCode: "677",
    isoCode: "SB",
    name: "Solomon Islands",
  );
  static const Country SC = Country(
    asset: "assets/flags/sc_flag.png",
    dialingCode: "248",
    isoCode: "SC",
    name: "Seychelles",
  );
  static const Country SD = Country(
    asset: "assets/flags/sd_flag.png",
    dialingCode: "249",
    isoCode: "SD",
    name: "Sudan",
  );
  static const Country SE = Country(
    asset: "assets/flags/se_flag.png",
    dialingCode: "46",
    isoCode: "SE",
    name: "Sweden",
  );
  static const Country SG = Country(
    asset: "assets/flags/sg_flag.png",
    dialingCode: "65",
    isoCode: "SG",
    name: "Singapore",
  );
  static const Country SH = Country(
    asset: "assets/flags/sh_flag.png",
    dialingCode: "290",
    isoCode: "SH",
    name: "Saint Helena",
  );
  static const Country SI = Country(
    asset: "assets/flags/si_flag.png",
    dialingCode: "386",
    isoCode: "SI",
    name: "Slovenia",
  );
  static const Country SJ = Country(
    asset: "assets/flags/sj_flag.png",
    dialingCode: "47",
    isoCode: "SJ",
    name: "Svalbard and Jan Mayen Islands",
  );
  static const Country SK = Country(
    asset: "assets/flags/sk_flag.png",
    dialingCode: "421",
    isoCode: "SK",
    name: "Slovakia",
  );
  static const Country SL = Country(
    asset: "assets/flags/sl_flag.png",
    dialingCode: "232",
    isoCode: "SL",
    name: "Sierra Leone",
  );
  static const Country SM = Country(
    asset: "assets/flags/sm_flag.png",
    dialingCode: "378",
    isoCode: "SM",
    name: "San Marino",
  );
  static const Country SN = Country(
    asset: "assets/flags/sn_flag.png",
    dialingCode: "221",
    isoCode: "SN",
    name: "Senegal",
  );
  static const Country SO = Country(
    asset: "assets/flags/so_flag.png",
    dialingCode: "252",
    isoCode: "SO",
    name: "Somalia",
  );
  static const Country SR = Country(
    asset: "assets/flags/sr_flag.png",
    dialingCode: "597",
    isoCode: "SR",
    name: "Suriname",
  );
  static const Country SS = Country(
    asset: "assets/flags/ss_flag.png",
    dialingCode: "211",
    isoCode: "SS",
    name: "South Sudan",
  );
  static const Country ST = Country(
    asset: "assets/flags/st_flag.png",
    dialingCode: "239",
    isoCode: "ST",
    name: "Sao Tome and Principe",
  );
  static const Country SV = Country(
    asset: "assets/flags/sv_flag.png",
    dialingCode: "503",
    isoCode: "SV",
    name: "El Salvador",
  );
  static const Country SX = Country(
    asset: "assets/flags/sx_flag.png",
    dialingCode: "1",
    isoCode: "SX",
    name: "Sint Maarten",
  );
  static const Country SY = Country(
    asset: "assets/flags/sy_flag.png",
    dialingCode: "963",
    isoCode: "SY",
    name: "Syrian Arab Republic",
  );
  static const Country SZ = Country(
    asset: "assets/flags/sz_flag.png",
    dialingCode: "268",
    isoCode: "SZ",
    name: "Swaziland",
  );
  static const Country TC = Country(
    asset: "assets/flags/tc_flag.png",
    dialingCode: "1",
    isoCode: "TC",
    name: "Turks and Caicos Islands",
  );
  static const Country TD = Country(
    asset: "assets/flags/td_flag.png",
    dialingCode: "235",
    isoCode: "TD",
    name: "Chad",
  );
  static const Country TF = Country(
    asset: "assets/flags/tf_flag.png",
    dialingCode: "262",
    isoCode: "TF",
    name: "French Southern Territories",
  );
  static const Country TG = Country(
    asset: "assets/flags/tg_flag.png",
    dialingCode: "228",
    isoCode: "TG",
    name: "Togo",
  );
  static const Country TH = Country(
    asset: "assets/flags/th_flag.png",
    dialingCode: "66",
    isoCode: "TH",
    name: "Thailand",
  );
  static const Country TJ = Country(
    asset: "assets/flags/tj_flag.png",
    dialingCode: "992",
    isoCode: "TJ",
    name: "Tajikistan",
  );
  static const Country TK = Country(
    asset: "assets/flags/tk_flag.png",
    dialingCode: "690",
    isoCode: "TK",
    name: "Tokelau",
  );
  static const Country TL = Country(
    asset: "assets/flags/tl_flag.png",
    dialingCode: "670",
    isoCode: "TL",
    name: "Timor-leste",
  );
  static const Country TM = Country(
    asset: "assets/flags/tm_flag.png",
    dialingCode: "993",
    isoCode: "TM",
    name: "Turkmenistan",
  );
  static const Country TN = Country(
    asset: "assets/flags/tn_flag.png",
    dialingCode: "216",
    isoCode: "TN",
    name: "Tunisia",
  );
  static const Country TO = Country(
    asset: "assets/flags/to_flag.png",
    dialingCode: "676",
    isoCode: "TO",
    name: "Tonga",
  );
  static const Country TR = Country(
    asset: "assets/flags/tr_flag.png",
    dialingCode: "90",
    isoCode: "TR",
    name: "Turkey",
  );
  static const Country TT = Country(
    asset: "assets/flags/tt_flag.png",
    dialingCode: "1",
    isoCode: "TT",
    name: "Trinidad and Tobago",
  );
  static const Country TV = Country(
    asset: "assets/flags/tv_flag.png",
    dialingCode: "688",
    isoCode: "TV",
    name: "Tuvalu",
  );
  static const Country TW = Country(
    asset: "assets/flags/tw_flag.png",
    dialingCode: "886",
    isoCode: "TW",
    name: "Taiwan",
  );
  static const Country TZ = Country(
    asset: "assets/flags/tz_flag.png",
    dialingCode: "255",
    isoCode: "TZ",
    name: "Tanzania, United Republic Of",
  );
  static const Country UA = Country(
    asset: "assets/flags/ua_flag.png",
    dialingCode: "380",
    isoCode: "UA",
    name: "Ukraine",
  );
  static const Country UG = Country(
    asset: "assets/flags/ug_flag.png",
    dialingCode: "256",
    isoCode: "UG",
    name: "Uganda",
  );
  static const Country UM = Country(
    asset: "assets/flags/um_flag.png",
    dialingCode: "1",
    isoCode: "UM",
    name: "United States Minor Outlying Islands",
  );
  static const Country US = Country(
    asset: "assets/flags/us_flag.png",
    dialingCode: "1",
    isoCode: "US",
    name: "United States",
  );
  static const Country UY = Country(
    asset: "assets/flags/uy_flag.png",
    dialingCode: "598",
    isoCode: "UY",
    name: "Uruguay",
  );
  static const Country UZ = Country(
    asset: "assets/flags/uz_flag.png",
    dialingCode: "998",
    isoCode: "UZ",
    name: "Uzbekistan",
  );
  static const Country VA = Country(
    asset: "assets/flags/va_flag.png",
    dialingCode: "379",
    isoCode: "VA",
    name: "Vatican City State (Holy See)",
  );
  static const Country VC = Country(
    asset: "assets/flags/vc_flag.png",
    dialingCode: "1",
    isoCode: "VC",
    name: "Saint Vincent and The Grenadines",
  );
  static const Country VE = Country(
    asset: "assets/flags/ve_flag.png",
    dialingCode: "58",
    isoCode: "VE",
    name: "Venezuela",
  );
  static const Country VG = Country(
    asset: "assets/flags/vg_flag.png",
    dialingCode: "1",
    isoCode: "VG",
    name: "Virgin Islands (British)",
  );
  static const Country VI = Country(
    asset: "assets/flags/vi_flag.png",
    dialingCode: "1",
    isoCode: "VI",
    name: "Virgin Islands (U.S.)",
  );
  static const Country VN = Country(
    asset: "assets/flags/vn_flag.png",
    dialingCode: "84",
    isoCode: "VN",
    name: "Viet Nam",
  );
  static const Country VU = Country(
    asset: "assets/flags/vu_flag.png",
    dialingCode: "678",
    isoCode: "VU",
    name: "Vanuatu",
  );
  static const Country WF = Country(
    asset: "assets/flags/wf_flag.png",
    dialingCode: "681",
    isoCode: "WF",
    name: "Wallis and Futuna Islands",
  );
  static const Country WS = Country(
    asset: "assets/flags/ws_flag.png",
    dialingCode: "685",
    isoCode: "WS",
    name: "Samoa",
  );
  static const Country YE = Country(
    asset: "assets/flags/ye_flag.png",
    dialingCode: "967",
    isoCode: "YE",
    name: "Yemen",
  );
  static const Country YT = Country(
    asset: "assets/flags/yt_flag.png",
    dialingCode: "262",
    isoCode: "YT",
    name: "Mayotte",
  );
  static const Country ZA = Country(
    asset: "assets/flags/za_flag.png",
    dialingCode: "27",
    isoCode: "ZA",
    name: "South Africa",
  );
  static const Country ZM = Country(
    asset: "assets/flags/zm_flag.png",
    dialingCode: "260",
    isoCode: "ZM",
    name: "Zambia",
  );
  static const Country ZW = Country(
    asset: "assets/flags/zw_flag.png",
    dialingCode: "263",
    isoCode: "ZW",
    name: "Zimbabwe",
  );

  /// All the countries in the picker list
  static const ALL = <Country>[
    AD,
    AE,
    AF,
    AG,
    AI,
    AL,
    AM,
    AO,
    AQ,
    AR,
    AS,
    AT,
    AU,
    AW,
    AX,
    AZ,
    BA,
    BB,
    BD,
    BE,
    BF,
    BG,
    BH,
    BI,
    BJ,
    BL,
    BM,
    BN,
    BO,
    BQ,
    BR,
    BS,
    BT,
    BV,
    BW,
    BY,
    BZ,
    CA,
    CC,
    CD,
    CF,
    CG,
    CH,
    CI,
    CK,
    CL,
    CM,
    CN,
    CO,
    CR,
    CU,
    CV,
    CW,
    CX,
    CY,
    CZ,
    DE,
    DJ,
    DK,
    DM,
    DO,
    DZ,
    EC,
    EE,
    EG,
    EH,
    ER,
    ES,
    ET,
    FI,
    FJ,
    FK,
    FM,
    FO,
    FR,
    GA,
    GB,
    GD,
    GE,
    GF,
    GG,
    GH,
    GI,
    GL,
    GM,
    GN,
    GP,
    GQ,
    GR,
    GS,
    GT,
    GU,
    GW,
    GY,
    HK,
    HM,
    HN,
    HR,
    HT,
    HU,
    ID,
    IE,
    IL,
    IM,
    IN,
    IO,
    IQ,
    IR,
    IS,
    IT,
    JE,
    JM,
    JO,
    JP,
    KE,
    KG,
    KH,
    KI,
    KM,
    KN,
    KP,
    KR,
    KW,
    KY,
    KZ,
    LA,
    LB,
    LC,
    LI,
    LK,
    LR,
    LS,
    LT,
    LU,
    LV,
    LY,
    MA,
    MC,
    MD,
    ME,
    MF,
    MG,
    MH,
    MK,
    ML,
    MM,
    MN,
    MO,
    MP,
    MQ,
    MR,
    MS,
    MT,
    MU,
    MV,
    MW,
    MX,
    MY,
    MZ,
    NA,
    NC,
    NE,
    NF,
    NG,
    NI,
    NL,
    NO,
    NP,
    NR,
    NU,
    NZ,
    OM,
    PA,
    PE,
    PF,
    PG,
    PH,
    PK,
    PL,
    PM,
    PN,
    PR,
    PS,
    PT,
    PW,
    PY,
    QA,
    RE,
    RO,
    RS,
    RU,
    RW,
    SA,
    SB,
    SC,
    SD,
    SE,
    SG,
    SH,
    SI,
    SJ,
    SK,
    SL,
    SM,
    SN,
    SO,
    SR,
    SS,
    ST,
    SV,
    SX,
    SY,
    SZ,
    TC,
    TD,
    TF,
    TG,
    TH,
    TJ,
    TK,
    TL,
    TM,
    TN,
    TO,
    TR,
    TT,
    TV,
    TW,
    TZ,
    UA,
    UG,
    UM,
    US,
    UY,
    UZ,
    VA,
    VC,
    VE,
    VG,
    VI,
    VN,
    VU,
    WF,
    WS,
    YE,
    YT,
    ZA,
    ZM,
    ZW,
  ];

  /// returns an country with the specified [isoCode] or ```null``` if
  /// none or more than 1 are found
  static findByIsoCode(String isoCode) {
    return ALL.singleWhere(
      (item) => item.isoCode == isoCode,
    );
  }

  /// Creates a copy with modified values
  Country copyWith({
    String name,
    String isoCode,
    String dialingCode,
  }) {
    return Country(
      name: name ?? this.name,
      isoCode: isoCode ?? this.isoCode,
      dialingCode: dialingCode ?? this.dialingCode,
      asset: asset ?? this.asset,
    );
  }
}
