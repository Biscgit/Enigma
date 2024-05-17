#![allow(deprecated)]

use pyo3::prelude::*;
use serde_json;


/// return the filtered plugboard list
#[pyfunction]
#[pyo3(name = "drop_plugboard_pair")]
fn remove_pb_pair(plugboard: Vec<Vec<char>>, mut pair: Vec<char>) -> PyResult<Vec<String>> {
    pair.sort_unstable();

    let result = plugboard
        .iter()
        .filter(|x| {
            let mut pb_pair = (*x).clone();
            pb_pair.sort_unstable();
            pb_pair != pair
        })
        .map(|x| {
            serde_json::to_string(x).unwrap()
        })
        .collect::<Vec<String>>();

    Ok(result)
}

#[pymodule]
#[pyo3(name = "rustlib")]
fn module_rustlib(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(remove_pb_pair, m)?)?;
    Ok(())
}
