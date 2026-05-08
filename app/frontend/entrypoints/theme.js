const applyTheme = () => {
  const theme = localStorage.getItem('theme')
  
  // Default to 'dark' if no theme is set, otherwise check if explicitly 'dark'
  if (theme === 'dark' || theme === null) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

applyTheme()
document.addEventListener('turbo:load', applyTheme)
