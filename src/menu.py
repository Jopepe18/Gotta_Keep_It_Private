from PySide6.QtCore import QObject, Slot, Signal, Property, Slot

class MenuBackend(QObject):
    # Signal to notify when current page changes
    page_changed = Signal(str)
    
    # Signal for user actions
    logout_requested = Signal()
    
    def __init__(self, auth_manager):
        super().__init__()
        self.auth_manager = auth_manager
        self._current_page = "dashboard"  # Default page after login
        self._current_user = None
    
    # Property to track current page (accessible from QML)
    @Property(str, notify=page_changed)
    def current_page(self):
        return self._current_page
    
    @current_page.setter
    def current_page(self, page):
        if self._current_page != page:
            self._current_page = page
            self.page_changed.emit(page)
            print(f"Navigated to: {page}")
    
    # Property for current username (accessible from QML)
    @Property(str)
    def username(self):
        return self._current_user if self._current_user else "Guest"
    
    # Method to set user after login
    def set_user(self, username):
        self._current_user = username
    
    @Slot(str)
    def navigate_to(self, page):
        """Navigate to a different page"""
        self.current_page = page
    
    @Slot()
    def logout(self):
        """Handle logout"""
        print(f"User {self._current_user} logging out")
        self._current_user = None
        self._current_page = "dashboard"
        self.logout_requested.emit()
