package com.example.mesh_ok

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

//convert a data class to a map
fun <T> T.convertObjectToMap(): Map<String, Any> {
    return convertSomethingToSomething()
}

//convert a map to a data class
inline fun <reified T> Map<String, Any>.convertMapToObject(): T {
    return convertSomethingToSomething()
}

//convert an object of type I to type O
inline fun <I, reified O> I.convertSomethingToSomething(): O {
    val gson = Gson()
    val json = gson.toJson(this)
    return gson.fromJson(json, object : TypeToken<O>() {}.type)
}
