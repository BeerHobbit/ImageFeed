import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func reloadRow(for cell: ImagesListCell)
}
