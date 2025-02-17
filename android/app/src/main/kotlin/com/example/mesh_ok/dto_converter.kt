package com.example.mesh_ok

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

// Convert a data class to a JSON
inline fun <T> T.convertObjectToJson(): String {
    return Gson().toJson(this)
}

// Convert a data class to a Map
fun <T> T.convertObjectToMap(): Map<String, Any> {
    return convertSomethingToSomething()
}

// Convert a Map to a data class
inline fun <reified T> Map<String, Any>.convertMapToObject(): T {
    return convertSomethingToSomething()
}

// Convert an object of type I to type O
inline fun <I, reified O> I.convertSomethingToSomething(): O {
    val gson = Gson()
    val json = gson.toJson(this)
    return gson.fromJson(json, object : TypeToken<O>() {}.type)
}
