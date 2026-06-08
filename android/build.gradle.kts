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

// Certains plugins (ex. screen_protector, file_picker) ne déclarent pas de
// jvmTarget Kotlin explicite : avec JDK 21, leur tâche Kotlin cible 21 alors
// que leur tâche Java cible la version qu'ils déclarent eux-mêmes (11, 17…),
// ce qui fait échouer la compilation ("Inconsistent JVM-target compatibility").
// Chaque plugin déclarant une cible Java différente, on ne peut pas forcer une
// valeur fixe : on aligne donc dynamiquement le jvmTarget Kotlin de chaque
// sous-projet sur SA PROPRE cible Java (compileOptions.targetCompatibility),
// sans modifier celle-ci (déjà finalisée par AGP au moment où ce bloc s'exécute).
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
