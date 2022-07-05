// RUN: %build
// RUN: grep "delegate.row = delegate._get('model')" %out/qml.model_row.js

Repeater {
    model: ListModel {}
    delegate: Item {
        property var row: model;
    }
}