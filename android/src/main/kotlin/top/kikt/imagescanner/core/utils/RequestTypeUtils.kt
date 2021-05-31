package top.kikt.imagescanner.core.utils

import android.provider.MediaStore

/// create 2020-03-20 by cai
object RequestTypeUtils {

  private const val typeImage = 1
  private const val typeVideo = 1.shl(1)
  private const val typeAudio = 1.shl(2)

  fun containsImage(type: Int): Boolean {
    return checkType(type, typeImage)
  }
  
  fun containsVideo(type: Int): Boolean {
    return checkType(type, typeVideo)
  }

  fun containsAudio(type: Int): Boolean {
    return checkType(type, typeAudio)
  }

  private fun checkType(type: Int, targetType: Int): Boolean {
    return type and targetType == targetType
  }

  fun getTypeCond(type: Int): TypeCond {
    val haveImage = containsImage(type)
    val haveVideo = containsVideo(type)
    val haveAudio = containsAudio(type)

    val typeList = ArrayList<String>()
    val argsList = ArrayList<String>()

    if (haveImage) {
      typeList.add("( ${MediaStore.Files.FileColumns.MEDIA_TYPE} = ? )")
      argsList.add(MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE.toString())
    }

    if (haveVideo) {
      typeList.add("( ${MediaStore.Files.FileColumns.MEDIA_TYPE} = ? )")
      argsList.add(MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO.toString())
    }

    if (haveAudio) {
      typeList.add("( ${MediaStore.Files.FileColumns.MEDIA_TYPE} = ? )")
      argsList.add(MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO.toString())
    }

    return TypeCond(typeList.joinToString(" OR "), argsList)
  }

  data class TypeCond(val typeWhere: String, val typeArgs: List<String>)
}