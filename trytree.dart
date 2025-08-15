void main() {
  int x = printNestedJson(data);
}

Map<String, dynamic> data = <String, dynamic>{
  "a": 1,
  "b": "heyyy",
  "c": 35,
  "d": {
    "da": 25.4,
    "db": 45.4,
    "dc": {
      "dca": "dcavalue",
      "dcb": "dcbvalue",
      "dcc": {
        "dcca": "further map",
        "dccb": [1, 2, 3],
      },
    },
  },
  "e": [1, 2, 3],
};

int printNestedJson(Map<String, dynamic> json, {int depth = 1}) {
  var spaceTab = "";
  for (int i = 0; i < depth; i++) {
    spaceTab += "  ";
  }
  if (depth >= 4) {
    print("${spaceTab}maxdepth: {}");

    return depth;
  }

  for (var entry in json.entries) {
    if (entry.value.runtimeType == (Map<String, dynamic>).runtimeType) {
      print("$spaceTab${entry.key}: {");

      return printNestedJson(entry.value, depth: depth++);
    }

    print("$spaceTab${entry.key}: ${entry.value}");
  }

  return depth++;
}
