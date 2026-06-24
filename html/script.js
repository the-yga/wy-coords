const app = document.getElementById("app")

const UI = {
    vector2: document.getElementById("vector2"),
    vector3: document.getElementById("vector3"),
    vector4: document.getElementById("vector4"),
    heading: document.getElementById("heading"),

    target: document.getElementById("target"),
    type: document.getElementById("type"),
    model: document.getElementById("model"),
    hash: document.getElementById("hash"),
    distance: document.getElementById("distance"),

    laserBox: document.getElementById("laserBox")
}

const format = {
    vec2: v => `vector2(${v.x.toFixed(2)}, ${v.y.toFixed(2)})`,
    vec3: v => `vector3(${v.x.toFixed(2)}, ${v.y.toFixed(2)}, ${v.z.toFixed(2)})`,
    vec4: v => `vector4(${v.x.toFixed(2)}, ${v.y.toFixed(2)}, ${v.z.toFixed(2)}, ${v.h.toFixed(2)})`
}

window.addEventListener("message", e => {

    const d = e.data

    switch (d.action) {

        case "open":
            app.style.display = "block"
            break

        case "close":
            app.style.display = "none"
            break

        case "player":

            UI.vector2.textContent = format.vec2(d.vector2)
            UI.vector3.textContent = format.vec3(d.vector3)
            UI.vector4.textContent = format.vec4(d.vector4)
            UI.heading.textContent = d.heading.toFixed(2)

            break

        case "laser":

            UI.laserBox.style.display = "block"

            UI.target.textContent = format.vec3(d.vector3)

            UI.type.textContent = d.type
            UI.model.textContent = d.model
            UI.hash.textContent = d.hash
            UI.distance.textContent = d.distance.toFixed(2) + "m"

            break

    }

})

function nui(event, data) {

    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    })

}

document.querySelectorAll("[data-copy]").forEach(btn => {

    btn.onclick = () => {

        const id = btn.dataset.copy
        const text = document.getElementById(id).textContent

        nui("copy", { text })

    }

})

document.querySelectorAll("[data-mode]").forEach(btn => {

    btn.onclick = () => {

        const mode = btn.dataset.mode

        document.querySelectorAll("[data-mode]").forEach(b => b.classList.remove("active"))
        btn.classList.add("active")

        UI.laserBox.style.display = mode === "laser" ? "block" : "none"

        nui("mode", { mode })

    }

})
