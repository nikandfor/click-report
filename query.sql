WITH
	(SELECT arg0 FROM _params) AS arg0
SELECT count() FROM q WHERE id = arg0
