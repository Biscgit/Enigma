#![allow(deprecated)]

use pyo3::prelude::*;

/// returns the length of a list
#[pyfunction]
fn list_length(letters: Vec<PyAny>) -> PyResult<usize> {
    Ok(letters.len())
}

#[pymodule]
#[pyo3(name = "rustlib")]
fn module_rustlib(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(list_length, m)?)?;
    Ok(())
}
