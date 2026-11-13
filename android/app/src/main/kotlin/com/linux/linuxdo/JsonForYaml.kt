package com.linux.linuxdo

/** Android JSONObject escapes '/' as '\/', which go-yaml rejects. Keep JSON semantics. */
internal fun jsonForYaml(json: String): String {
    val result = StringBuilder(json.length)
    var backslashes = 0
    for (character in json) {
        if (character == '/' && backslashes % 2 == 1) result.setLength(result.length - 1)
        result.append(character)
        backslashes = if (character == '\\') backslashes + 1 else 0
    }
    return result.toString()
}
