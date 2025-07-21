
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const String INDENT = '    ';

// result types
const int SUCCESS = 0;
const int FAILURE = 1;
const int NO_ACTION = 2;

final Map< String, Color > colors = {
    'red'  : Colors.red,
    'blue' : Colors.blue,
    'black': Colors.black,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'cyan': Colors.cyan,
    'brown': Colors.brown,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'grey': Colors.grey,
    'lime': Colors.lime,
    'pink': Colors.pink
};

const String ERR_MSG = "error_message";
const String ERROR = "error";
const String WARNING = "warning";
const String NOTICE = "notice";
const String STACK = "stack_trace";

// events
const String UPDATE = "update";

