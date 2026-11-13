package com.linux.linuxdo

import org.junit.Assert.assertEquals
import org.junit.Test

class JsonForYamlTest {
    @Test fun urlsAndWebsocketPathsAreAcceptedByYaml() {
        assertEquals("""{"url":"https://example.invalid/a","path":"/ws"}""",
            jsonForYaml("""{"url":"https:\/\/example.invalid\/a","path":"\/ws"}"""))
    }
    @Test fun literalBackslashesInCredentialsArePreserved() {
        assertEquals("""{"value":"\\/"}""", jsonForYaml("""{"value":"\\\/"}"""))
        assertEquals("""{"value":"\\/"}""", jsonForYaml("""{"value":"\\/"}"""))
    }
    @Test fun otherJsonEscapesRemainUnchanged() {
        val value = """{"value":"line\nquote\"slash\\unicode\u4e2d"}"""
        assertEquals(value, jsonForYaml(value))
    }
}
