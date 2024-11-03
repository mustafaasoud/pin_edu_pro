// ignore_for_file: non_constant_identifier_names, unnecessary_late

import 'package:pin_edu_pro/Models/Project_Model.dart';
import 'package:pin_edu_pro/Models/School_Model.dart';

String? UsernameEntry, Password, School_Name, userRole;
String? School_name_Admin;
late List<project_model> project_List = [];
late List<School_Model> school_List = [];
late List<dynamic> onlineuser = [];

String URLPage = '172.25.11.18:3000';
final Map<String, List<String>> syriaCitiesAndDistricts = {
  'Idleb': [
    'Ariha',
    'Idleb',
    'Jisr al-Shughur',
    'Maarrat al-Nu\'man',
    'Saraqib'
  ],
  'Aleppo': ['Aleppo', 'Manbij', 'Al-Bab', 'Azaz', 'Afrin'],
  'Damascus': ['Damascus', 'Douma', 'Harasta', 'Jobar', 'Barzeh'],
  'Hama': ['Hama', 'Masyaf', 'Salamiyah', 'Al-Ghab', 'Al-Suqaylabiyah'],
  'Homs': ['Homs', 'Rastan', 'Talkalakh', 'Al-Qusayr', 'Al-Hawash'],
  'Latakia': ['Latakia', 'Jableh', 'Qardaha', 'Al-Haffah', 'Kassab'],
  'Tartus': ['Tartus', 'Baniyas', 'Safita', 'Duraykish', 'Qadmous'],
  'Deir ez-Zor': [
    'Deir ez-Zor',
    'Al-Mayadin',
    'Al-Bukamal',
    'Ashara',
    'Al-Quriyah'
  ],
  'Raqqa': ['Raqqa', 'Al-Thawrah', 'Tabqa', 'Suluk', 'Ayn Issa'],
  'Hasakah': ['Hasakah', 'Qamishli', 'Ras al-Ayn', 'Al-Malikiyah', 'Shaddadi'],
  'Daraa': ['Daraa', 'Nawa', 'Izra', 'Al-Sanamayn', 'Jasim'],
  'Sweida': ['Sweida', 'Salkhad', 'Shahba', 'Qarayya', 'Al-Mazraa'],
  'Quneitra': [
    'Quneitra',
    'Khan Arnabah',
    'Al-Harra',
    'Rafid',
    'Al-Qahtaniyah'
  ],
};
//'mustafanetidlib-001-site1.itempurl.com';