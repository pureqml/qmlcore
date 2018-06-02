Object {
	signal reset;			///< model reset signal
	signal rowsInserted;	///< rows inserted signal
	signal rowsChanged;		///< rows changed signal
	signal rowsRemoved;		///< rows removed signal

	property int count;		///< model rows count. Please note that you can't directly/indirectly modify model from onChanged handler. Use view.onCountChanged instead
}
