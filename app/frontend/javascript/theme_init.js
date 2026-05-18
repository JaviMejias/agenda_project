(function () {
  const applyTheme = () => {
    try {
      const theme = localStorage.getItem('theme') || 'dark'
      const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      const isDark = theme === 'dark' || (theme === 'system' && systemPrefersDark)

      if (isDark) {
        document.documentElement.classList.add('dark')
        document.documentElement.style.colorScheme = 'dark'
        document.documentElement.style.backgroundColor = '#020617'
      } else {
        document.documentElement.classList.remove('dark')
        document.documentElement.style.colorScheme = 'light'
        document.documentElement.style.backgroundColor = ''
      }
    } catch (e) {
      document.documentElement.classList.add('dark')
    }
  }

  applyTheme()

  document.addEventListener('turbo:load', applyTheme)
})()
