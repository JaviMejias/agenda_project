import { application } from "./application"

const controllers = import.meta.glob("./**/*_controller.js", { eager: true })

for (const path in controllers) {
  const match = path.match(/\.\/(.+)_controller\.[jt]s$/)
  if (match) {
    const name = match[1].replace(/\//g, "--").replace(/_/g, "-")
    application.register(name, controllers[path].default)
  }
}
