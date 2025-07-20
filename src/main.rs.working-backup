use gtk4::prelude::*;
use gtk4::{glib, Application, ApplicationWindow, Box, Button, Label, ListBox, ScrolledWindow, TextView};
use std::cell::RefCell;
use std::rc::Rc;
use std::fs;
use std::path::PathBuf;

const APP_ID: &str = "com.example.cosmic-notes";

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
struct Note {
    title: String,
    content: String,
    timestamp: String,
}

// Helper function to get the notes file path
fn get_notes_file_path() -> PathBuf {
    let mut path = dirs::config_dir().unwrap_or_else(|| PathBuf::from("."));
    path.push("cosmic-notes");
    fs::create_dir_all(&path).ok();
    path.push("notes.json");
    path
}

// Load notes from disk
fn load_notes() -> Vec<Note> {
    let notes_file = get_notes_file_path();
    
    if notes_file.exists() {
        if let Ok(content) = fs::read_to_string(&notes_file) {
            if let Ok(notes) = serde_json::from_str::<Vec<Note>>(&content) {
                if !notes.is_empty() {
                    return notes;
                }
            }
        }
    }
    
    // Return default note if file doesn't exist or is empty
    vec![Note {
        title: "Welcome to Cosmic Notes".to_string(),
        content: "Welcome to Cosmic Notes!\n\nThis is your first note. You can edit this text and create new notes using the + button.\n\nTips:\n• Notes are automatically saved to disk\n• Click 'Save' to manually save\n• The title comes from your first line\n• Your notes are stored in ~/.config/cosmic-notes/".to_string(),
        timestamp: chrono::Local::now().format("%Y-%m-%d %H:%M").to_string(),
    }]
}

// Save notes to disk
fn save_notes(notes: &[Note]) {
    let notes_file = get_notes_file_path();
    
    if let Ok(json) = serde_json::to_string_pretty(notes) {
        if let Err(e) = fs::write(&notes_file, json) {
            eprintln!("Failed to save notes: {}", e);
        }
    }
}

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(|app| {
        build_ui(app);
    });

    app.run()
}

fn build_ui(app: &Application) {
    // Load notes from disk
    let initial_notes = load_notes();
    let notes = Rc::new(RefCell::new(initial_notes));
    let current_note = Rc::new(RefCell::new(0));

    // Create the main window
    let window = ApplicationWindow::builder()
        .application(app)
        .title("Cosmic Notes")
        .default_width(350)
        .default_height(450)
        .resizable(true)
        .build();

    // Create the main container
    let main_box = Box::new(gtk4::Orientation::Vertical, 8);
    main_box.set_margin_start(8);
    main_box.set_margin_end(8);
    main_box.set_margin_top(8);
    main_box.set_margin_bottom(8);

    // Create header with title and buttons
    let header_box = Box::new(gtk4::Orientation::Horizontal, 8);
    let title_label = Label::builder()
        .use_markup(true)
        .label("<b>Notes</b>")
        .halign(gtk4::Align::Start)
        .build();
    
    let new_note_button = Button::with_label("+ New");
    let save_button = Button::with_label("Save");
    let delete_button = Button::with_label("🗑");
    let close_button = Button::with_label("×");
    
    new_note_button.add_css_class("suggested-action");
    save_button.add_css_class("accent");
    delete_button.add_css_class("destructive-action");
    close_button.add_css_class("destructive-action");

    header_box.append(&title_label);
    header_box.set_hexpand(true);
    
    let button_box = Box::new(gtk4::Orientation::Horizontal, 4);
    button_box.append(&new_note_button);
    button_box.append(&save_button);
    button_box.append(&delete_button);
    button_box.append(&close_button);
    button_box.set_halign(gtk4::Align::End);
    
    header_box.append(&button_box);

    // Create notes list
    let notes_list = ListBox::builder()
        .selection_mode(gtk4::SelectionMode::Single)
        .margin_start(8)
        .margin_end(8)
        .margin_top(4)
        .margin_bottom(4)
        .build();

    let notes_scroll = ScrolledWindow::builder()
        .height_request(120)
        .vscrollbar_policy(gtk4::PolicyType::Automatic)
        .hscrollbar_policy(gtk4::PolicyType::Never)
        .build();
    notes_scroll.set_child(Some(&notes_list));

    // Create text view
    let text_view = TextView::builder()
        .wrap_mode(gtk4::WrapMode::Word)
        .margin_start(8)
        .margin_end(8)
        .margin_top(8)
        .margin_bottom(8)
        .accepts_tab(false)
        .build();

    let text_scroll = ScrolledWindow::builder()
        .vexpand(true)
        .vscrollbar_policy(gtk4::PolicyType::Automatic)
        .hscrollbar_policy(gtk4::PolicyType::Never)
        .build();
    text_scroll.set_child(Some(&text_view));

    // Add everything to main box
    main_box.append(&header_box);
    main_box.append(&notes_scroll);
    main_box.append(&text_scroll);

    window.set_child(Some(&main_box));

    // Helper functions
    let refresh_notes_list = {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let notes_list = notes_list.clone();
        
        move || {
            // Clear existing items
            while let Some(child) = notes_list.first_child() {
                notes_list.remove(&child);
            }

            // Add all notes
            let notes_ref = notes.borrow();
            let current_index = *current_note.borrow();
            
            for (i, note) in notes_ref.iter().enumerate() {
                let row_box = Box::new(gtk4::Orientation::Vertical, 2);
                row_box.set_margin_start(8);
                row_box.set_margin_end(8);
                row_box.set_margin_top(6);
                row_box.set_margin_bottom(6);

                let title_label = Label::new(Some(&note.title));
                title_label.set_halign(gtk4::Align::Start);
                title_label.set_ellipsize(gtk4::pango::EllipsizeMode::End);
                if i == current_index {
                    title_label.add_css_class("accent");
                }

                let time_label = Label::new(Some(&note.timestamp));
                time_label.set_halign(gtk4::Align::Start);
                time_label.add_css_class("dim-label");
                time_label.add_css_class("caption");

                row_box.append(&title_label);
                row_box.append(&time_label);

                notes_list.append(&row_box);
            }

            // Select the current note
            if let Some(row) = notes_list.row_at_index(current_index as i32) {
                notes_list.select_row(Some(&row));
            }
        }
    };

    let load_current_note = {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let text_view = text_view.clone();
        
        move || {
            let notes_ref = notes.borrow();
            let current_index = *current_note.borrow();
            
            if let Some(note) = notes_ref.get(current_index) {
                let buffer = text_view.buffer();
                buffer.set_text(&note.content);
            }
        }
    };

    let save_current_note = {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let text_view = text_view.clone();
        
        move || {
            let buffer = text_view.buffer();
            let start = buffer.start_iter();
            let end = buffer.end_iter();
            let content = buffer.text(&start, &end, false);

            let current_index = *current_note.borrow();
            let mut notes_ref = notes.borrow_mut();
            
            if let Some(note) = notes_ref.get_mut(current_index) {
                note.content = content.to_string();
                
                // Update title from first line
                let title = content
                    .lines()
                    .next()
                    .unwrap_or("Untitled")
                    .trim()
                    .chars()
                    .take(40)
                    .collect::<String>();
                note.title = if title.is_empty() {
                    "Untitled".to_string()
                } else {
                    title
                };
                
                note.timestamp = chrono::Local::now().format("%Y-%m-%d %H:%M").to_string();
            }
            
            // Save to disk after updating
            save_notes(&notes_ref);
        }
    };

    // Load initial data
    refresh_notes_list();
    load_current_note();

    // Connect signals
    
    // New note button
    {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let refresh_notes_list = refresh_notes_list.clone();
        let load_current_note = load_current_note.clone();
        let text_view = text_view.clone();
        
        new_note_button.connect_clicked(move |_| {
            let new_note = Note {
                title: "New Note".to_string(),
                content: "".to_string(),
                timestamp: chrono::Local::now().format("%Y-%m-%d %H:%M").to_string(),
            };
            
            notes.borrow_mut().push(new_note);
            let new_index = notes.borrow().len() - 1;
            *current_note.borrow_mut() = new_index;
            
            // Save to disk after adding new note
            save_notes(&notes.borrow());
            
            refresh_notes_list();
            load_current_note();
            text_view.grab_focus();
        });
    }

    // Save button
    {
        let save_current_note = save_current_note.clone();
        let refresh_notes_list = refresh_notes_list.clone();
        
        save_button.connect_clicked(move |_| {
            save_current_note();
            refresh_notes_list();
        });
    }

    // Delete button
    {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let refresh_notes_list = refresh_notes_list.clone();
        let load_current_note = load_current_note.clone();
        
        delete_button.connect_clicked(move |_| {
            let notes_len = notes.borrow().len();
            if notes_len > 1 {  // Don't delete the last note
                let current_index = *current_note.borrow();
                notes.borrow_mut().remove(current_index);
                
                // Adjust current note index if needed
                let new_current = if current_index >= notes.borrow().len() {
                    notes.borrow().len() - 1
                } else {
                    current_index
                };
                *current_note.borrow_mut() = new_current;
                
                // Save to disk after deletion
                save_notes(&notes.borrow());
                
                refresh_notes_list();
                load_current_note();
            }
        });
    }

    // Close button
    {
        let window = window.clone();
        close_button.connect_clicked(move |_| {
            window.close();
        });
    }

    // Notes list selection - auto-save when switching
    {
        let notes = notes.clone();
        let current_note = current_note.clone();
        let load_current_note = load_current_note.clone();
        let save_current_note = save_current_note.clone();
        
        notes_list.connect_row_selected(move |_, row| {
            if let Some(row) = row {
                let index = row.index() as usize;
                let current_index = *current_note.borrow();
                
                // Save current note before switching (if it's different)
                if index != current_index && index < notes.borrow().len() {
                    save_current_note();
                    *current_note.borrow_mut() = index;
                    load_current_note();
                }
            }
        });
    }

    window.present();
}
