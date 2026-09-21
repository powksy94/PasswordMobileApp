allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Some plugins (e.g. screen_protector, file_picker) do not declare an explicit
// Kotlin jvmTarget: with JDK 21, their Kotlin task targets 21 while
// their Java task targets the version they declare themselves (11, 17...),
// which makes the compilation fail ("Inconsistent JVM-target compatibility").
// Since each plugin declares a different Java target, we cannot force a
// fixed value: we therefore dynamically align the Kotlin jvmTarget of each
// subproject on ITS OWN Java target (compileOptions.targetCompatibility),
// without modifying the latter (already finalized by AGP when this block runs).
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        val javaTarget = project.extensions.findByType<com.android.build.gradle.BaseExtension>()
            ?.compileOptions?.targetCompatibility
            ?: JavaVersion.VERSION_17
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(javaTarget.toString()))
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
