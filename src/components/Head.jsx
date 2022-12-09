import React from 'react';
import { Helmet } from 'react-helmet';

export default function Head(props) {
  var page_title = 'ΕΛ.ΙΔ.Ε.Κ.';
  if (props.title) {
    page_title += ' | ' + props.title
  }

  return (
    <>
      <Helmet title={page_title} />
    </>
  )
}
